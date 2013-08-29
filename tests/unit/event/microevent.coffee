Event = require '../../../lib/event/microevent'

class Extended extends Event

class Mixed
  Event.mixin @

obj = {}
Event.mixin obj

describe '[microevent]', ->

  describe '[extended]', ->

    it 'should listen for `once` just one time', ->
      called = 0
      tmp = new Extended
      tmp.once 'vai', -> called++
      tmp.emit 'vai'
      tmp.emit 'vai'
      called.should.be.equal 1

      called = 0
      tmp = new Mixed
      tmp.once 'vai', -> called++
      tmp.emit 'vai'
      tmp.emit 'vai'
      called.should.be.equal 1

      called = 0
      obj.once 'vai', t = -> called++
      obj.emit 'vai'
      obj.emit 'vai'
      called.should.be.equal 1
      obj.off t

    it 'should listen for `once` just one time', ->
      called = 0
      tmp = new Extended
      tmp.on 'vai', t = -> called++
      tmp.off 'vai', t
      tmp.emit 'vai'
      tmp.emit 'vai'
      called.should.be.equal 0

      called = 0
      tmp = new Mixed
      tmp.on 'vai', t = -> called++
      tmp.off 'vai', t
      tmp.emit 'vai'
      tmp.emit 'vai'
      called.should.be.equal 0

      called = 0
      obj.on 'vai', -> called++
      obj.off 'vai', -> called++
      obj.emit 'vai'
      obj.emit 'vai'
      called.should.be.equal 0