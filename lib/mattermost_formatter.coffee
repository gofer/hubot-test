class MattermostFormatter
  @to_link = (url, text) -> '[' + text + '](' + url + ')'

  @to_image = (url, alt='', title='') ->
    
    '![' + alt + '](' + url + ' \"' + title + '\")'

  @to_check_list = (list) ->
    list
      .map((line) -> '- [ ] ' + line)
      .join('\n')

  @build_table = (head, body) ->
    build_row = (col) -> '| ' + col.join(' | ') + ' |'
    seprater = Array(head.length).fill(':---:')
    [head, seprater].concat(body)
      .map(build_row)
      .join('\n')

exports.to_link       = MattermostFormatter.to_link
exports.to_check_list = MattermostFormatter.to_check_list
exports.build_table   = MattermostFormatter.build_table