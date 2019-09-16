class MattermostFormatter
  @to_link = (url, text) -> '[' + text + '](' + url + ')'

  @build_table = (head, body) ->
    build_row = (col) -> '| ' + col.join(' | ') + ' |'
    seprater = Array(head.length).fill('---')
    [head, seprater].concat(body)
      .map(build_row)
      .join('\n')

exports.to_link     = MattermostFormatter.to_link
exports.build_table = MattermostFormatter.build_table