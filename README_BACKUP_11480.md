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

<<<<<<< HEAD
In a mostly-complete beta state. No function call safeguards have been implemented,
but it is feature-complete and, with proper usage, nothing should go wrong.

I no longer have the time to continue work on this project; forks are welcome.
=======
Currently in beta; most features are properly implemented but no safeguards are in place for improper usage.

## Usage

(Mostly TBD)

From GML, call gca_init() ONCE before calling anything else.  
Call gca_attach() to attempt to connect to an adapter.  
Call gca_begin_tick() once per frame to fetch input from the adapter.  
Call gca_end_tick() to commit changed rumble states to the adapter.  
>>>>>>> 90abd343f38cc5e43a330d01a43b22988a37fb00

## License

This code is publicly licensed under the GNU LGPL 3.0.
If your project needs a more permissive license, please contact me at dwillbarron \<at\> gmail (dot) com.

