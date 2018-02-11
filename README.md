# gm_gcn_adapt
Extension to introduce native Gamecube Controller Adapter support to Gamemaker: Studio projects

## Building & Usage

### Compiling the DLL:

Compiled using Visual Studio 2017 (likely works with others, though)  
Depends on libusb (32 bit)  
Compile to a 32 bit windows DLL.  

### Using the plugin:

Check the sample GM:S project included under /GCControl.gmx/.  
Export the GCN_ADAPT extension and import it to your project.  
Next, add GCA_Init.gml from the sample project to your project.  
Most functions have usage information as comments. To see them  
in action, check the draw function of object0 in the sample project.  

## Development Status

In a mostly-complete beta state. No function call safeguards have been implemented,
but it is feature-complete and, with proper usage, nothing should go wrong.

I no longer have the time to continue work on this project; forks are welcome.

## License

This code is publicly licensed under the GNU LGPL 3.0.
If your project needs a more permissive license, please contact me at dwillbarron \<at\> gmail (dot) com.

