# SCXcodeSwitchExpander

SCXcodeSwitchExpander is a small Xcode plugin that expands switch statements by inserting missing cases.

### Features

- inserts all possible switch cases

- keeps already used cases and only inserts missing ones (even if the type changes)

- only keeps the 'default:' case when used with the built-in Xcode snippet

- works on ivars, properties, method parameters etc.

- works with nested switches

- hooks into the undo manager stack (makes it easier to fix typos)

- fast and reliable (won't affect Xcode's performance in any signinficant way)

### Screenshots

- Replacing the default Xcode snippet
![DefaultSnippet](https://drive.google.com/uc?export=download&id=0ByLCkUO90ltoMEVfNjVLdHg5UXM)

- Inserting missing cases
![MissingInsertion](https://drive.google.com/uc?export=download&id=0ByLCkUO90ltoV3hJQjhCamdtdXM)

### Known Issues

- takes a bit for it to kick in after starting Xcode as it's waiting for the IDEIndexDidChange notification. I found that building the project usually makes that happen.

- does not work with anonymous enums

### Installation

- Build the project and restart Xcode or ...

- Download SCXcodeSwitchExpander.xcplugin.zip from the releases tab, unzip and move it to the  Xcode plugins folder ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/SCXcodeSwitchExpander.xcplugin and restart Xcode or ...

- Get it through [Alcatraz](https://github.com/alcatraz/Alcatraz)

- If you encounter any issues you can uninstall it by removing the ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/SCXcodeSwitchExpander.xcplugin folder
 
### Contact
Any suggestions or improvements are more than welcome. Feel free to contact me at [stefan.ceriu@yahoo.com](mailto:stefan.ceriu@yahoo.com) or [@stefanceriu](https://twitter.com/stefanceriu).


### License

MIT License

    Copyright (c) 2014 Stefan Ceriu
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
    Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    
