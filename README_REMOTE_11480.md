# gm_gcn_adapt
Extension to introduce native Gamecube Controller Adapter support to Gamemaker: Studio projects

## Development Status

Currently in beta; most features are properly implemented but no safeguards are in place for improper usage.

## Usage

(Mostly TBD)

From GML, call gca_init() ONCE before calling anything else.  
Call gca_attach() to attempt to connect to an adapter.  
Call gca_begin_tick() once per frame to fetch input from the adapter.  
Call gca_end_tick() to commit changed rumble states to the adapter.  

## License

This code is publicly licensed under the GNU GPL 3.0.
If your project needs a license compatible with proprietary code, please contact me at dwillbarron \<at\> gmail (dot) com.

