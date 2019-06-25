This is a helper script to do the heavy lifting for kiosking a raspberry pi to an already running MagicMirror Server.
This script has issues being ran over ssh and is not recommended.
<b>NOTE: Do NOT run this script more than once without re-imaging your Rpi.  It will cause multiple instances of the nodes and electron and will lock the Rpi up.</b>

For help setting up a MagicMirror Server please visit the <a href="https://github.com/MichMich/MagicMirror">MagicMirror</a> github page.

The latest version of Electron was running out of memory when using the MagicMirror Client.  This was causing the Pi to reap electron.  The result was a blank black screen.  This is not due to screen saver or power saver.  The solution is to change the value in /etc/sysctl.d/98-rpi.conf to  vm.min_free_kbytes = 1024 

<p id=disclaim><b>IN NO EVENT WILL WE BE LIABLE FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL, SPECIAL OR EXEMPLARY DAMAGES FOR ANY USE OF THIS SITE, OR USE OF ANY OTHER LINKED SITE, OR SOFTWARE, EVEN IF WE ARE ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.</b></br></br></p>
