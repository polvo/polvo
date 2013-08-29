Event = require '../../../lib/event/microevent'

class Extended extends Event

class Mixed
  constructor:->
    Event.mixin @


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