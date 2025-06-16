{
  description = "Aider-desk development environment";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nodejs = pkgs.nodejs;
        
        # Import the node2nix generated expressions
        node2nixOutput = import ./nix { 
          inherit pkgs nodejs system; 
        };
        
      in {
        # Development shell with all dependencies
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            npm
            nodePackages.node2nix
          ];
          
          shellHook = ''
            # Set NODE_PATH to include generated node modules
            export NODE_PATH=${node2nixOutput.nodeDependencies}/lib/node_modules
            echo "Aider-desk development environment loaded"
            echo "Node.js version: $(node --version)"
            echo "NPM version: $(npm --version)"
          '';
        };
        
        # Alternative shell using node2nix shell directly
        devShells.node2nix = node2nixOutput.shell;
        
        # Package output if you want to build the project
        packages.default = node2nixOutput.package;
      }
    );
}
