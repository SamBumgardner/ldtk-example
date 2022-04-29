# LDtk Example
A quick HaxeFlixel project put together to test out the API. 
Will hopefully be useful for sharing examples with folks after I get it working.

## Setup
Actually setting up local environment was a bit tricky. 
 - Needed to follow the instructions here to install requirements: https://github.com/deepnight/ldtk-haxe-api#requirements
 - To be safe, run `haxelib upgrade` to force your local libraries to update to whatever newest versions are available.
 - Needed to set up Lime to compile to Hashlink (this is the nicer, more efficient replacement for Neko!) by running
    ```
    lime setup hl
    ```
    Lime setup required me to download Hashlink Binaries (I grabbed the recommended 1.10.0 version). 
    
    I un-archived the downloaded files to a memorable spot in my computer, then provided the filepath to that un-archived directory to the command line prompt.


## Usage
After you've finished the above setup, you should be able to build the project with
```
lime test hl -debug
```

When built for HashLink in debug mode, you can press `R` to reload the state and it'll pull the 
newest version of your LDtk project from the assets folder.

Control the player characters with the `A` and `D` keys, press spacebar to jump.

The 'goal' is to make the two players completely overlap one another. When they're combined, a victory message pops up in the top-right corner of the screen.