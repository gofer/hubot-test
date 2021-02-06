Helper = require('hubot-test-helper')
helper = new Helper('../scripts/test.coffee')

Promise = require('bluebird')

expect = require('chai').expect
co = require('co')

describe 'test', ->
  room = null
  
  beforeEach ->
    room = helper.createRoom()
  
  afterEach ->
    room.destroy()
  
  context 'test #1', ->
    beforeEach ->
      room.user.say 'gofer', 'heybot'
    
    it 'are you bot?', ->
      console.log('room.messages = ', room.messages)
      expect(room.messages).eql([
        ['gofer', 'heybot'],
        ['hubot', 'Yes, I\'m bot!']
      ])
  
  context 'test #2', ->
    beforeEach ->
      room.user.say 'gofer', 'heybot wow'
    
    it '因果WOWWOWですか?', ->
      console.log('room.messages = ', room.messages)
      expect(room.messages).eql([
        ['gofer', 'heybot wow'],
        ['hubot', '因果WOWWOWって奴ですね']
      ])
  
  context 'test #3', ->
    beforeEach ->
      co ->
        yield room.user.say 'gofer', 'heybot weather'
        yield new Promise.delay(1000)
    
    it 'お天気いかが?', ->
      console.log('room.messages = ', room.messages)
      
      console.log('room.messages[0] = ', room.messages[0])
      expect(room.messages[0]).eql(['gofer', 'heybot weather'])
      
      console.log('room.messages[1] = ', room.messages[1])
      expect(room.messages[1][0]).eql('hubot')
