# Clipboard

Xclip vs. Xsel: A Detailed Comparison
Reading from an Input File

One of the differences between xclip and xsel is how they handle input files. xclip can read from an input file directly using the -i or -in option followed by the filename. For example:

xclip -i input.txt

On the other hand, xsel requires shell redirection to read from a file. Here’s how you can do it:

xsel < input.txt

Output Redirection

xclip allows the output of the clipboard to be redirected to a file using the -o or -out option. This can be useful when you want to save the contents of the clipboard to a file. For example:

xclip -o > output.txt

xsel, however, only offers output to stdout, which can then be redirected to a file:

xsel > output.txt

Dependencies

In terms of dependencies, xsel has fewer dependencies compared to xclip. This might be a consideration if you’re working in a constrained environment or if you’re trying to keep your system lean.
Handling Binary Data

One area where xclip shines is its ability to handle binary data from the clipboard, such as screenshots. This can be done using the -t option followed by the appropriate MIME type. For example:

xclip -t image/png -o > screenshot.png

However, xsel may have limitations when it comes to handling binary data.
Manipulating Cut Buffers

xclip can manipulate cut buffer 0 by passing the -selection buffer-cut option. xsel does not have this feature built-in, but a patch is available that allows xsel to manipulate other cut buffers.

Copying something to the primary buffer

echo hi | xclip -i -selection primary or, since it is the default behavior: echo hi | xclip

echo hi | xsel -i -p, or: echo hi | xsel, since primary selection is also its default buffer.
Copying to clipboard

echo clip | xclip -i -selection clipboard, or echo clip | xclip -se c.

The abbreviated form is possible since xclip options are accepted as soon as they are unambiguous (so, xclip -s is not possible since it has both -selection and -silent options), and the selection argument only needs a first letter to be valid (p, s, or c).

echo clip | xsel -i --clipboard, or echo clip | xsel -b

xsel generally keeps to the GNU convention of having long-form options after two dashes and single-letter versions with one dash.
Outputting clipboard contents

xclip -selection clipboard -out | less, or xclip -se c -o | less

xsel --clipboard --output, or xsel -bo
Clearing clipboard contents

echo "" | xclip -se c — xclip does not have an explicit option to clear, but has to be ‘filled’ with emptiness to overwrite the buffer.

xsel --clipboard --clear, or xsel -bc
Automatically clearing clipboard contents

The two programs have different ideas of automation — xclip works with a number of clipboard invocations, while xsel works with a simple timer.

echo gone | xclip -selection clipboard -loops 3, or echo gone | xclip -se c -l 3, will ensure that after 3 pastes xclip exits and thus effectively removes the contents it contains from being pasted.

echo gone | xsel --clipboard ----selectionTimeout 3000, or echo gone | xsel -bt 3000, will keep the selection in the clipboard for 3 seconds (3000 milliseconds) and then exit xsel, same as xclip.

One thing to consider is that, while the xclip invocation count works perfectly as is, with some clipboard managers (in my case greenclip) the buffers are continually read. That means, it invokes the buffer and xclip counts this as one of its loops. So, using a clipboard manager, xsel offers the more reliable method of clearing here, even if the invocations idea is very nifty (e.g. clear passwords from clipboard after first paste).
File redirection

While both work with an invocation of cat:

cat myfile.txt | xclip

cat myfile.txt | xsel

xclip can additionally read files directly (xclip myfile.txt), which xsel can not do. Here, however, you can just use file redirection to avoid the cat-call as well: xsel -b < myfile.txt

Similarly, you can of course redirect the outputs to a file:

xsel -bo > myfile.txt

xclip -o -se c > myfile.txt
Data formats

One area where xclip generally shines is dealing with different data formats. It can extract binary data from the clipboard, making it possible to store screenshots in there, for example:

maim -s | xclip -se c -t image/png

Sometimes, the target does not have to be specified, though this can be tricky and sometimes does not recognize the correct format.

To output a list of all available targets, you can invoke xclip -o -t TARGETS. 1

xsel, as far as I am aware, simply does not deal with binary formats, and has no option to set a target format or anything of the sort.
Non-interactive behaviors

There are some differences between the two programs when invoked in scripts or non-interactive shell sessions which can lead to some headaches if not known about.

Generally, xsel should be preferred in many non-interactive contexts over xclip.

First of all, xclip does not close its stdout when reading from another copy buffer. That is the reason for e.g. the Arch Wiki recommending to prefer xsel over xclip when trying to integrate and scrape the tmux clipboard.

Secondly, there is a behavior in xclip which does not let it correctly detach from non-interactive bash sessions, as documented here. xclip does not completely fork off, or detach from the parent terminal session, and thus exits when its parent session exits.

This behavior can be fatal (and very frustrating to debug) when trying to invoke xclip in shell scripts which work with sub-shells (e.g. $(echo process substitution | xclip)). While xsel has a specific option to keep itself attached to a terminal (--nodetach, -n) if desired, xclip can not provide the opposite.

Conclusion

Which one to use should largely remain a question of personal preference, especially regarding their syntax usage for day-to-day operations, since those really do diverge between the programs.

Personally, I am not a fan of xclip’s long options being behind the same single dash as its short options, as well as no single-letter option existing for some of its most frequent operations (e.g. selecting clipboard). In general, I feel like the way options are structure in xsel makes more sense to me — they are separated in input, output, and actions, and can be respectively combined with a selection to work on — while xclip seems a bit less structured.

That being said, the data formats of xclip make it basically a necessity to use when you want to copy rich-content to and from the clipboard.

For scripts, and also the reason I wrote this post in the first place, I might switch to using xsel in the future, since the xclip behavior of closing with the parent terminal makes things really hard to accomplish in some more advanced scripts.

Lastly, I think I prefer xsel’s method of emptying its contents after a specified amount of time. It’s predictable, is easy to inform the user about, and does not interfere with any running clipboard managers or similar. Some people like to create a wrapper (called e.g. copy) which invokes one of the two programs, depending on availability, clipping needs, and personal preference. 2

But on the whole, both programs are wonderful options for interacting with the X server’s clipboards and paste selections, and both authors deserve my full gratitude for making my life easier basically every single day I am working on my PC — from automating password entries, quickly copying long file names and paths, to sharing URLs — they massively ease the headaches of getting data from one application into another on any X server installation.
