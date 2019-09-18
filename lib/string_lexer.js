class LexerError extends Error {
  constructor(mesg) {
    super(mesg);
    this.name = this.constructor.name;
  }
}

class Lexer {
  static split_by_space(str) {
    let result = [];
    let temp = '';
    let mode = 'regular';
    
    for (let index = 0; index < str.length; ++index) {
      //console.log(index, str[index], mode, temp);
      if (str[index] == '\\') {
        temp += str[index];
        ++index;
      } else if (str[index] == ' ') {
        if (mode == 'regular') {
          result.push(temp);
          temp = '';
          continue;
        }
      } else if (str[index] == '"') {
        if (mode == 'regular') {
          mode = 'dquote';
        } else if (mode == 'dquote') {
          mode = 'regular';
        } else {
          throw new LexerError('quote mismatch');
        }
      } else if (str[index] == '\'') {
        if (mode == 'regular') {
          mode = 'squote';
        } else if (mode == 'squote') {
          mode = 'regular';
        } else {
          throw new LexerError('quote mismatch');
        }
      }
      temp += str[index];
    }
    
    if (mode != 'regular') {
      throw new LexerError('quote mismatch');
    }
    
    if (temp.length > 0) {
      result.push(temp);
    }
    
    return result;
  }
}

module.exports = Lexer;