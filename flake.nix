{
  description = "Flake for AGISIT";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: inputs.utils.lib.eachDefaultSystem (system:
    let
      pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };
      gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
        gke-gcloud-auth-plugin
      ]);
    in
    {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          terraform
          gdk
          kubectl
          python3
          python311Packages.requests
        ];
     };
  });
}