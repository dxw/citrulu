CodeMirror.defineMode('Citrulu', function(conf) {
    var ERRORCLASS = 'error';

    function wordRegexp(words) {
        return new RegExp("^((" + words.join(")|(") + "))\\b");
    }

    var onclause       = wordRegexp(['On', 'When I', 'to', 'So I know that']);
    var methodclause   = wordRegexp(['get', 'post', 'put', 'head', 'delete']);
    var firstfinally   = wordRegexp(['First, fetch', 'Finally, fetch']);
    var assertion      = wordRegexp(["Source should contain", "Source should not contain", "I should see", "I should not see", "Headers should include", "Headers should not include", "Header", "should contain", "should not contain", "Response code should be", "Response code should not be"]);

    var name           = new RegExp('^:([a-zA-Z0-9_]+)');
    var http_header    = new RegExp('^[a-z-A-Z0-9-]+');
    var value          = new RegExp('^([^:]+[^\\n]*)|(::[^\\n]*)');
    var url            = new RegExp('^((http:\/\/)|(https:\/\/))[a-zA-Z-0-9]+[^\\s\\n]+');

    // Tokenizers
    function tokenBase(stream, state) {
        if (stream.eatSpace()) {
            return 'whitespace';
        }

        var ch = stream.peek();

        // Single line comment
        if (ch === '#') {
            stream.skipToEnd();
            return 'comment';
        }

        if (ch == '"') {
          var eaten = 0;
          var prev_ch = stream.next();
          while((ch = stream.next()) && ch != "\n") {
            if (ch == '"' && prev_ch != '\\') {
              return 'text'
            }

            prev_ch = ch;
            eaten++;
          }

          if (ch != '"') {
            stream.backUp(eaten)
          }
        }

        if (stream.match(onclause)) {
            return 'variable';
        }

        if (stream.match(assertion)) {
            return 'variable';
        }

        if (stream.match(firstfinally)) {
            return 'string';
        }

        if (stream.match(url)) {
            return 'link';
        }

        if (stream.match(methodclause)) {
            return "variable-2"
        }

        if (stream.string.match(/^\s*Header /) && stream.match(http_header)) {
            return 'text';
        }

        if (stream.match(value)) {
            if (stream.string.match(/^\s*So /)) {
              return 'number';
            }

            return 'text';
        }

        if (stream.match(name)) {
            return 'variable-2';
        }

        // Handle non-detected items
        stream.next();
        return ERRORCLASS;
    }

    function tokenLexer(stream, state) {
        return state.tokenize(stream, state);
    }

    var external = {
        startState: function(base) {
            return {
              tokenize: tokenBase,
              lastToken: null,
              indented: 0,
          };
        },

        token: function(stream, state) {
            var style = tokenLexer(stream, state);

            state.lastToken = {style:style, content: stream.current()};

            return style;
        },

        indent: function(state, textAfter) {
          if (state.lastToken.style == 'link' || state.lastToken.style == 'variable-2' || state.lastToken.style == 'text') {
            return 2;
          }

          return 0;
        }

    };
    return external;
});

CodeMirror.defineMIME('text/citrulu-tests', 'Citrulu');
