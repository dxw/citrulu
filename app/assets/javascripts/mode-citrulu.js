/**
 * Link to the project's GitHub page:
 * https://github.com/pickhardt/coffeescript-codemirror-mode
 */
CodeMirror.defineMode('coffeescript', function(conf) {
    var ERRORCLASS = 'error';

    function wordRegexp(words) {
        return new RegExp("^((" + words.join(")|(") + "))\\b");
    }

    var onclause       = wordRegexp(['On']);
    var firstfinally   = wordRegexp(['First, fetch', 'Finally, fetch']);
    var assertion      = wordRegexp(["Source should contain", "Source should not contain", "I should see", "I should not see", "Headers should include", "Headers should not include"]);

    var name           = new RegExp(":[a-zA-Z0-9_]*");
    var value          = new RegExp("(::[^\n]*)|([^\n]*)");
    var url            = new RegExp("((http:\/\/)|('https:\/\/'))[^\n]+");

    var indentKeywords = wordRegexp(['On']);

    // Tokenizers
    function tokenBase(stream, state) {
        if (stream.eatSpace()) {
            return null;
        }

        var ch = stream.peek();

        // Single line comment
        if (ch === '#') {
            stream.skipToEnd();
            return 'comment';
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

        if (stream.match(name)) {
            return 'variable-2';
        }

        if (stream.match(value)) {
            return 'text';
        }


        // Handle non-detected items
        stream.next();
        return ERRORCLASS;
    }

    function indent(stream, state, type) {
        type = type || 'coffee';
        var indentUnit = 0;
        if (type === 'coffee') {
            for (var i = 0; i < state.scopes.length; i++) {
                if (state.scopes[i].type === 'coffee') {
                    indentUnit = state.scopes[i].offset + conf.indentUnit;
                    break;
                }
            }
        } else {
            indentUnit = stream.column() + stream.current().length;
        }
        state.scopes.unshift({
            offset: indentUnit,
            type: type
        });
    }

    function dedent(stream, state) {
        if (state.scopes.length == 1) return;
        if (state.scopes[0].type === 'coffee') {
            var _indent = stream.indentation();
            var _indent_index = -1;
            for (var i = 0; i < state.scopes.length; ++i) {
                if (_indent === state.scopes[i].offset) {
                    _indent_index = i;
                    break;
                }
            }
            if (_indent_index === -1) {
                return true;
            }
            while (state.scopes[0].offset !== _indent) {
                state.scopes.shift();
            }
            return false
        } else {
            state.scopes.shift();
            return false;
        }
    }

    function tokenLexer(stream, state) {
        var style = state.tokenize(stream, state);
        var current = stream.current();

        if ( style === 'indent') {
            indent(stream, state);
        }

        if (style === 'dedent') {
            if (dedent(stream, state)) {
                return ERRORCLASS;
            }
        }

        return style;
    }

    var external = {
        startState: function(basecolumn) {
            return {
              tokenize: tokenBase,
              scopes: [{offset:basecolumn || 0, type:'coffee'}],
              lastToken: null,
              lambda: false,
              dedent: 0
          };
        },

        token: function(stream, state) {
            var style = tokenLexer(stream, state);

            state.lastToken = {style:style, content: stream.current()};

            if (stream.eol() && stream.lambda) {
                state.lambda = false;
            }

            return style;
        },

        indent: function(state, textAfter) {
            if (state.tokenize != tokenBase) {
                return 0;
            }

            return state.scopes[0].offset;
        }

    };
    return external;
});

CodeMirror.defineMIME('text/x-citrulu-tests', 'Citrulu tests');
