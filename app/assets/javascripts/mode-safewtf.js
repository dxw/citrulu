define('ace/mode/safewtf', function(require, exports, module) {

  var oop = require("pilot/oop");
  var TextMode = require("ace/mode/text").Mode;
  var Tokenizer = require("ace/tokenizer").Tokenizer;
  var SafeWTFHighlightRules = require("ace/mode/safewtf_highlight_rules").SafeWTFHighlightRules;

  var Mode = function() {
    this.$tokenizer = new Tokenizer(new SafeWTFHighlightRules().getRules());
  };

  oop.inherits(Mode, TextMode);

  (function() {
    this.getNextLineIndent = function(state, line, tab) { 
      var indent = this.$getIndent(line);

      if(line.match('^On')) {
        indent += tab;
      }

      return indent;
    };
  }).call(Mode.prototype);

  exports.Mode = Mode;
});

define('ace/mode/safewtf_highlight_rules', function(require, exports, module) {

  var oop = require("pilot/oop");
  var TextHighlightRules = require("ace/mode/text_highlight_rules").TextHighlightRules;

  var SafeWTFHighlightRules = function() {
    this.$rules =  {
      "start" : [
        {
          token: "keyword",
          regex: "On"
        },

        {
          token: "constant",
          regex: "I should see|I should not see"
        },

        {
          token: "variable",
          regex: "=[a-zA-Z0-9 _-]+"
        },

        {
          token: "string",
          regex: "http://.*|https://.*"
        }
      ] 
    }
  }

  oop.inherits(SafeWTFHighlightRules, TextHighlightRules);

  exports.SafeWTFHighlightRules = SafeWTFHighlightRules;
});
