require 'test_helper'

class AnnotationsControllerTest < ActionController::TestCase

  it "has proper routes" do
    assert_recognizes({ controller: 'annotations', action: 'print' }, '/notes/print')
    assert_recognizes({ controller: 'annotations', action: 'cors_options', document_id:"2", id:"1",
        "allowed_methods"=>[:put, :delete, :post] },
      { path: '/documents/2/annotations/1',  method: :options } )
    assert_recognizes({ controller: 'annotations', action: 'cors_options', document_id:"2",
        "allowed_methods"=>[:get, :post] },
      { path: '/documents/2/annotation',  method: :options } )
  end

  def setup
    login_account!
  end

  test "index" do
    get :index, :document_id => doc.id
    assert_response 200
    assert_equal  doc.annotation_ids.sort, json_body.map{|note| note['id'] }.sort
  end

  test "show" do
    note = doc.annotations.first
    get :show, :id=>note.id, :document_id => doc.id, :format=>:js
    assert_response 200
    assert_match( /\"id\":#{note.id}/, @response.body )
  end

  test "print" do
    get :print, :docs=>[doc.id,secret_doc.id]
    doc.annotations.each do | note |
      assert_match( /#{note.content}/, @response.body )
    end
  end


  test "create" do
    assert_difference( 'Annotation.count', 1 ) do
      put :create, :document_id=>doc.id, :page_number=>2, :title=>'Test Note',
          :content=>'this is a note', :location=>23, :access=>Document::PUBLIC
    end
  end

  test "update" do
    note = doc.annotations.first
    post :update, :document_id=>doc.id, :id=>note.id, :title=>'New Title',
         :content=>'I have become death the destroyer of worlds', :access=>'private'
    assert_response :success
    note.reload
    assert_equal 'New Title', note.title
    assert_equal 'I have become death the destroyer of worlds', note.content
    assert_equal Annotation::PRIVATE, note.access
  end

  test "destroy" do
    note = doc.annotations.first
    delete :destroy, :document_id=>doc.id, :id=>note.id
    assert_raises(ActiveRecord::RecordNotFound){
      doc.annotations.find( note.id )
    }
  end

  test "cors_options" do
    get :cors_options
    assert_response 400
    request.headers['Origin']='http://test.com/'
    get :cors_options, :allowed_methods=>['GET']
    assert_response :success
    assert_equal 'http://test.com/', response.headers['Access-Control-Allow-Origin']
    %w{ OPTIONS GET POST PUT DELETE}.each do | method |
      assert_includes cors_allowed_methods, method
    end
    %w{ Accept Authorization Content-Length Content-Type Cookie }.each do | header |
      assert_includes cors_allowed_headers, header
    end
  end


end
