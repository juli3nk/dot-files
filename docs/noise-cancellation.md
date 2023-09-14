https://wiki.archlinux.org/title/PipeWire#WebRTC_screen_sharing
https://forum.endeavouros.com/t/pipewire-filter-chains-normalize-audio-noise-suppression/31661
https://medium.com/@gamunu/linux-noise-cancellation-b9f997f6764d
https://github.com/noisetorch/NoiseTorch

```nix
{ config, pkgs, ... }:

let
    json = pkgs.formats.json {};
    pw_rnnoise_config = {
        "context.modules"= [
            {
                "name" = "libpipewire-module-filter-chain";
                "args" = {
                    "node.description" = "Noise Canceling source";
                    "media.name"       = "Noise Canceling source";
                    "filter.graph" = {
                        "nodes" = [
                            {
                                "type"   = "ladspa";
                                "name"   = "rnnoise";
                                "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                                "label"  = "noise_suppressor_stereo";
                                "control" = {
                                    "VAD Threshold (%)" = 50.0;
                                };
                            }
                        ];
                    };
                    "audio.position" = [ "FL" "FR" ];
                    "capture.props" = {
                        "node.name" = "effect_input.rnnoise";
                        "node.passive" = true;
                    };
                    "playback.props" = {
                        "node.name" = "effect_output.rnnoise";
                        "media.class" = "Audio/Source";
                    };
                };
            }
        ];
    };
in
{
    environment.etc."pipewire/pipewire.conf.d/99-input-denoising.conf" = {
        source = json.generate "99-input-denoising.conf" pw_rnnoise_config;
    };
}
```

https://github.com/mozilla/policy-templates
https://wiki.archlinux.org/title/Firefox/Tweaks
