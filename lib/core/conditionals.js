/**
 * Exports module.
 * @type {Function}
 */
module.exports = parse;

/**
 * Parse all conditional compilation instructions in the given code
 *
 *  polvo:if
 *  polvo:else
 *  polvo:elif
 *  polvo:fi
 * 
 * @param  {String} code String of code to process
 * @return {String} Parsed code
 */
function parse(code) {
  var block, before, after;
  var reg = /^.+polvo:if([\s\S]+?)polvo:fi.*$/gm;
  var copy = code;

  while((block = reg.exec(code))) {
    before = block[0];
    after = parse_block(before);
    copy = copy.replace(before, after);
  }

  return copy;
}


/**
 * Parse all conditionals of the given code-block
 * @param  {String} code Code-block to parse
 * @return {String} Parsed code-block
 */
function parse_block(code) {
  var buffer = '';
  var passed = 0;
  var capturing = false;

  var i;
  var lines;
  var line;

  var expression;
  var property;
  var operator;
  var expected;

  lines = block.split('\n');

  for(i = 0; i < lines.length; i++) {
    line = lines[i];
    
    if(/polvo:(if|elif)/.test(line)) {

      expression = line.match(/(\w+)\s*(\!?=)\s*(\w+)/);
      property = expression[1];
      operator = expression[2];
      expected = expression[3];

      if(operator === '=')
        capturing = process.env[property] === expected;
      else if(operator === '!=')
        capturing = process.env[property] !== expected;

      if(capturing) passed++;
      continue;

    } else if(/polvo:else/.test(line)) {
      capturing = passed === 0;
      continue;

    } else if(/polvo:fi/.test(line)) {
      return buffer;

    } else if(capturing) {
      buffer += line + '\n';
    }
  }
}