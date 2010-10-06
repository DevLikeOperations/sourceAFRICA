// Mixin for collections which should be made selectable.
dc.model.Selectable = {

  firstSelection : null,

  selectedCount : 0,

  selectAll : function() {
    this.each(function(m){ m.set({selected : true}); });
  },

  deselectAll : function() {
    this.each(function(m){ m.set({selected : false}); });
  },

  selected : function() {
    return this.select(function(m){ return m.get('selected'); });
  },

  selectedIds : function() {
    return _.pluck(this.selected(), 'id');
  },

  _resetSelection : function() {
    this.firstSelection = null;
    this.selectedCount = 0;
  },

  _add : function(model, options) {
    if (model._attributes.selected == null) model._attributes.selected = false;
    Backbone.Collection.prototype._add.call(this, model, options);
    if (model.get('selected')) this.selectedCount += 1;
  },

  _remove : function(model, options) {
    Backbone.Collection.prototype._remove.call(this, model, options);
    if (this.selectedCount > 0 && model.get('selected')) this.selectedCount -= 1;
  },

  // We override "_onModelChange" to fire selection changed events when models
  // change their selected state.
  _onModelChange : function(model) {
    Backbone.Collection.prototype._onModelChange.call(this, model);
    if (model.hasChanged('selected')) {
      var selected = model.get('selected');
      if (selected && this.selectedCount == 0) {
        this.firstSelection = model;
      } else if (!selected && this.firstSelection == model) {
        this.firstSelection = null;
      }
      this.selectedCount += selected ? 1 : -1;
      _.defer(_(this.trigger).bind(this, 'select', this));
    }
  }

};