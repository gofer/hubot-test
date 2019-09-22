class MattermostFormatter
  @to_link: (url, text) -> '[' + text + '](' + url + ')'

  @to_image: (url, alt='', title='') ->
    '![' + alt + '](' + url + ' \"' + title + '\")'

  build_list = (prefix, list, prefix_tab = 0) ->
    prefix = Array(prefix_tab).fill('  ').join('') + prefix
    list.map((line) -> prefix + line).join('\n')

  @to_list: (list, prefix_tab = 0) ->
    build_list '- ', list, prefix_tab
  
  @to_enumerate: (list, prefix_tab = 0, start = 1) ->
    build_list (start.toString() + '. '), list, prefix_tab

  with_box         = (str) -> '[ ] ' + str
  with_checked_box = (str) -> '[x] ' + str

  @to_check_list: (list) ->
    MattermostFormatter.to_list(
      list.map with_box
    )

  @build_table: (head, body) ->
    build_row = (col) -> '| ' + col.join(' | ') + ' |'
    seprater = Array(head.length).fill(':---:')
    [head, seprater].concat(body)
      .map(build_row)
      .join('\n')

exports.to_link       = MattermostFormatter.to_link
exports.to_list       = MattermostFormatter.to_list
exports.to_enumerate  = MattermostFormatter.to_enumerate
exports.to_check_list = MattermostFormatter.to_check_list
exports.build_table   = MattermostFormatter.build_table