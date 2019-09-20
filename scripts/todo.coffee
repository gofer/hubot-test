# Description:
#   Hubot ToDo List application
#
# Commands:
#   hubot todo            - Reply ToDo list
#   hubot todo list       - Reply ToDo list
#   hubot todo add [task] - Add task to ToDo list
#   hubot todo forget     - Reomove all task from ToDo list

MattermostFormatter = require '../lib/mattermost_formatter'

module.exports = (robot) ->
  ToDoListBrainKey = 'todo'
  
  get_todo_list = ->
    list = robot.brain.get ToDoListBrainKey
    return if (list == null) then [] else list
  
  set_todo_list = (list) ->
    robot.brain.set ToDoListBrainKey, list
  
  list_to_message = (list) ->
    list = MattermostFormatter.to_check_list list
    
    if list.length == 0
      return 'ToDo 何も覚えていない…'
    else
      return 'ToDo で覚えているのは次の通りだよ!\n\n' + list
  
  robot.hear /^heybot todo$/i, (res) ->
    res.reply (list_to_message get_todo_list())

  robot.hear /^heybot todo list$/i, (res) ->
    res.reply (list_to_message get_todo_list())
  
  robot.hear /^heybot todo add (.*)$/i, (res) ->
    list = get_todo_list()
    list.push(res.match[1])
    set_todo_list list
    
    res.reply 'ToDo \"' + res.match[1] + '\" 覚えた!'

  robot.hear /^heybot todo forget$/i, (res) ->
    set_todo_list []
    
    res.reply 'ToDo 全部忘れた!'