{any, obj-to-pairs, join, find, each, map, filter} = Polymer.GladPreludeLs
{dasherize, camelize} = Polymer.GladPreludeLs
{underscore, titleize} = Polymer.GladInflection

class GladListView
  is: \glad-list-view
  properties:
    fields:
      type: Array
    rows:
      type: Array
    selected-rows:
      notify: on
    is-selecting:
      notify: on
  observers: [
    "toggle_class_on_changed(isSelecting)"
  ]
  toggle_class_on_changed: (is-selecting)->
    @toggle-class \is-selecting, is-selecting
  clear_selection: ->
    unless @selected-rows? => return
    @splice \selectedRows, 0, @selected-rows.length
    if @is-selecting then @set \isSelecting, no
  select_or_unselect_all: ({target: {checked}})->
    @clear_selection!
    if checked
      @rows |> each @~push \selectedRows, _
  is_selected_by: (row, selected-rows)-> row in selected-rows
  flex_class_by: ({flex_width}:field)-> "flex-#flex_width"
  icon_type_by: (field, row)->
    row.cols.(field.name |> camelize |> underscore).icon?.type
  icon_color_by: (field, row)->
    row.cols.(field.name |> camelize |> underscore).icon?.color
  values_by: (field, row)->
    | row.cols.(field.name |> camelize |> underscore).multi =>
      row.cols.(field.name |> camelize |> underscore).values
    | _ =>
      [row.cols.(field.name |> camelize |> underscore).value]
  href_by: (field, row)->
    row.cols.(field.name |> camelize |> underscore).href
  style_by: (field, row)->
    row.cols.(field.name |> camelize |> underscore).style
    |> ( or {})
    |> obj-to-pairs
    |> map ([key, val])-> "#{key |> dasherize}: #val;"
    |> join " "
  class_by: (field, row)->
    field.class
  has_action_by: (field, row)->
    [
      field.action
      @href_by field, row
    ] |> any (?)
  do_the_action: ({target: {field, row, value}}:event)->
    if @href_by field, row |> (?) then event.stop-propagation!
    unless field.action? => return
    event.stop-propagation!
    @dom-host~(field.action)? event, field, row, value
  display_name_of: (field)->
    field.name |> camelize |> underscore |> titleize
|> ( .::) |> Polymer

