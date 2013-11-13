polvo = require '../../../lib/polvo'

describe '[acceptance] version + help', ->
  it 'should show version number `-v`', ->
    errors = outs = 0

    options = version: true
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(version) ->
        outs++
        version.should.equal require('../../../package.json').version

    version = polvo options, stdio

    outs.should.equal 1
    errors.should.equal 0

  it 'should show the help screen `-h`', ->
    errors = outs = 0

    options = help: true
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(help) ->
        outs++
        help.indexOf('Polyvalent cephalopod mollusc').should.not.equal -1
        help.indexOf('Usage').should.not.equal -1
        help.indexOf('Options').should.not.equal -1
        help.indexOf('Examples').should.not.equal -1

    help = polvo options, stdio
    help = polvo {}, stdio

    outs.should.equal 2
    errors.should.equal 0