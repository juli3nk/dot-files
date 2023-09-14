# Secure delete files

Warning: Modern disk/SSD hardware and modern filesystems may squirrel away data in places where you cannot delete them, so this process may still leave data on the disk. The only safe ways of wiping data are the ATA Secure Erase command (if implemented correctly), or physical destruction. Also see How can I reliably erase all information on a hard drive?

Whether there is more security in filling the "free space" only 1 time with 0x00 or 38 times with different cabalistic standards is more of an academic discussion. The author of the seminal 1996 paper on shredding wrote himself an epilogue saying that this is obsolete and unecessary for modern hardware. There is no documented case of data being physically replaced zeroes and recovered afterwards.

The true fragile link in this procedure is the filesystem. Some filesystems reserve space for special use, and it is not made available as "free space". But your data may be there. That includes photos, personal plain-text emails, whatever. I have just googled reserved+space+ext4 and learned that 5% of my home partition was reserved. I guess this is where photorec found so much of my stuff. Conclusion: the shredding method is not the most important, even the multi-pass method still leaves data in place.

You can try # tune2fs -m 0 /dev/sdn0 before mounting it. (If this will be the root partition after rebooting, make sure run -m 5 or -m 1 after unmounting it).

But still, one way or another, there may be some space left.

The only truly safe way is to wipe the whole partition, create a filesystem again, and then restore your files from a backup.

##
### Secure-Delete

You can use a suite of tools called secure-delete.

```shell
sudo apt-get install secure-delete
```

This has four tools:

srm - securely delete an existing file
smem - securely delete traces of a file from ram
sfill - wipe all the space marked as empty on your hard drive
sswap - wipe all the data from you swap space.

From the man page of srm

    srm is designed to delete data on mediums in a secure manner which can not be recovered by thiefs, law enforcement or other threats. The wipe algorithm is based on the paper "Secure Deletion of Data from Magnetic and Solid-State Memory" presented at the 6th Usenix Security Symposium by Peter Gutmann, one of the leading civilian cryptographers.

    The secure data deletion process of srm goes like this:

        1 pass with 0xff
        5 random passes. /dev/urandom is used for a secure RNG if available.
        27 passes with special values defined by Peter Gutmann.
        5 random passes. /dev/urandom is used for a secure RNG if available.
        Rename the file to a random value
        Truncate the file

    As an additional measure of security, the file is opened in O_SYNC mode and after each pass an fsync() call is done. srm writes 32k blocks for the purpose of speed, filling buffers of disk caches to force them to flush and overwriting old data which belonged to the file.

### Zeroed file
#### Fast way (recommended)

Run from a directory on the filesystem you want to wipe:

```shell
dd if=/dev/zero of=zero.small.file bs=1024 count=102400
dd if=/dev/zero of=zero.file bs=1024
sync ; sleep 60 ; sync
rm zero.small.file
rm zero.file
```

Notes: the purpose of the small file is to reduce the time when free space is completely zero; the purpose of sync is to make sure the data is actually written.

This should be good enough for most people.

#### Slow way (paranoid)

There is no documented case of data being recovered after the above cleaning. It would be expensive and resource demanding, if possible at all.

Yet, if you have a reason to think that secret agencies would spend a lot of resources to recover your files, this should be enough:

```shell
dd if=/dev/urandom of=random.small.file bs=1024 count=102400
dd if=/dev/urandom of=random.file bs=1024
sync ; sleep 60 ; sync
rm random.small.file
rm random.file
```

It takes much longer time.

Warning. If you have chosen the paranoid way, after this you would still want to do the fast wipe, and that's not paranoia. The presence of purely random data is easy and cheap to detect, and raises the suspicion that it is actually encrypted data. You may die under torture for not revealing the decryption key.

#### Very slow way (crazy paranoid)

Even the author of the seminal 1996 paper on shredding wrote an epilogue saying that this is obsolete and unecessary for modern hardware.

But if yet you have a lot of free time and you don't mind wasting your disk with a lot of overwritting, there it goes:

```shell
dd if=/dev/zero of=zero.small.file bs=1024 count=102400
sync ; sleep 60 ; sync
shred -z zero.small.file
dd if=/dev/zero of=zero.file bs=1024
sync ; sleep 60 ; sync
rm zero.small.file
shred -z zero.file
sync ; sleep 60 ; sync
rm zero.file
```

Note: this is essentially equivalent to using the secure-delete tool.

## Misc

All of the above should work on any filesystem.

### File Size Limits

This may have problems with file size limits on some filesystems.

For FAT32 it would definitely be a concern due to the 2GiB file limit: most volumes are larger than this these days (8TiB is the volume size limit IIRC). You can work around this by piping the large cat /dev/zero output output through split to generate multiple smaller files and adjust the shred and delete stages accordingly.

With ext2/3/4 it is less of a concern: with the default/common 4K block the file size limit is 2TiB so you'd have to have a huge volume for this to be an issue (the maximum volume size under these conditions is 16TiB).

With the (still experimental) btrfs both the maximum file and volume sizes are a massive 16EiB.

Under NTFS the max file length is larger than max volume length in some cases even.

Starting points for more info:
http://en.wikipedia.org/wiki/Ext3#Size_limits
http://en.wikipedia.org/wiki/Btrfs
http://en.wikipedia.org/wiki/Ntfs#Scalability

### Virtual Devices

As mentioned in the comments recently, there are extra considerations for virtual devices:

    For sparsely allocated virtual disks other methods such as those used by zerofree will be faster (though unlike cat and dd this is not a standard tool that you can rely on being available in pretty much any unix-a-like OS).

    Be aware that zeroing a block on a sparse virtual device may not wipe the block on the underlying physical device, in fact I would go as far to say that it is unlikely to - the virtual disk manager will just make the block as no longer used so it can be allocated to something else later.

    Even for fixed size virtual devices, you may have no control of where the device lives physically so it could be moved around its current location or onto a new set of physical disks at any time and the most you can wipe is the current location, not any previous locations the block may have resided in the past.

    For the above problems on virtual devices: unless you control the host(s) and can do a secure wipe of their unallocated space afterward wiping the disks in the VM or moving the virtual device around, there is nothing you can do about this after the fact. The only recourse is to use full disk encryption from the start so nothing unencrypted is every written to the physical media in the first place. There may still be call for a free-space wipe within the VM of course. Note also that FDE can make sparse virtual devices much less useful as the virtualisation layer can't really see which blocks are unused. If the OS's filesystem layer sends trim commands to the virtual device (as if it is an SSD), and the virtual controller interprets these, then that may solve this, but I don't know of any circumstances where this actually happens and a wider discussion of that is a matter for elsewhere (we are already getting close to being off topic for the original question, so if this has piqued your interest some experimentation and/or follow-up questions may be in order).

### sdelete.sh

```shell
# Install the secure-delete package (sfill command).

# To see progress type in new terminal:
# watch -n 1 df -hm

# Assuming that there is one partition (/dev/sda1). sfill writes to /.
# The second pass writes in current directory and synchronizes data.
# If you have a swap partition then disable it by editing /etc/fstab
# and use "sswap" or similar to wipe it out.

# Some filesystems such as ext4 reserve 5% of disk space
# for special use, for example for the /home directory.
# In such case sfill won't wipe out that free space. You
# can remove that reserved space with the tune2fs command.
# See http://superuser.com/a/150757
# and https://www.google.com/search?q=reserved+space+ext4+sfill

sudo tune2fs -m 0 /dev/sda1
sudo tune2fs -l /dev/sda1 | grep 'Reserved block count'

sudo sfill -vfllz /

# sfill with the -f (fast) option won't synchronize the data to
# make sure that all was actually written. Without the fast option
# it is way too slow, so doing another pass in some other way with
# synchronization. Unfortunately this does not seem to be perfect,
# as I've watched free space by running the "watch -n 1 df -hm"
# command and I could see that there was still some available space
# left (tested on a SSD drive).

dd if=/dev/zero of=zero.small.file bs=1024 count=102400
dd if=/dev/zero of=zero.file bs=1024
sync ; sleep 60 ; sync
rm zero.small.file
rm zero.file

sudo tune2fs -m 5 /dev/sda1
sudo tune2fs -l /dev/sda1 | grep 'Reserved block count'
```
