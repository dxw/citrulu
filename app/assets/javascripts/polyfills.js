''.trim || (String.prototype.trim = // Use the native method if available, otherwise define a polyfill:
  function () { // trim returns a new string (which replace supports)
    return this.replace(/^[\s\uFEFF]+|[\s\uFEFF]+$/g,'') // trim the left and right sides of the string
  })
