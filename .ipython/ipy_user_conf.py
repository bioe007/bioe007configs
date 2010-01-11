""" User configuration file for IPython

This is a more flexible and safe way to configure ipython than *rc files
(ipythonrc, ipythonrc-pysh etc.)

This file is always imported on ipython startup. You can import the
ipython extensions you need here (see IPython/Extensions directory).

Feel free to edit this file to customize your ipython experience.

Note that as such this file does nothing, for backwards compatibility.
Consult e.g. file 'ipy_profile_sh.py' for an example of the things 
you can do here.

See http://ipython.scipy.org/moin/IpythonExtensionApi for detailed
description on what you could do here.
"""

# Most of your config files and extensions will probably start with this import

import IPython.ipapi
ip = IPython.ipapi.get()

# You probably want to uncomment this if you did %upgrade -nolegacy
# import ipy_defaults    

import os

print("IPYTHON: Start ipy_user_conf.py")

def main():

    # uncomment if you want to get ipython -p sh behaviour
    # without having to use command line switches  
    # import ipy_profile_sh

    # Configure your favourite editor?
    # Good idea e.g. for %edit os.path.isfile

    # import ipy_editors
    # Or roll your own:
    # ipy_editors.install_editor("/home/perry/.bin/vim-start.sh +$line $file")
    
    o = ip.options
    # An example on how to set options
    o.autocall        = 1
    o.autoedit_syntax = 0
    o.autoindent      = 1
    o.automagic       = 1
    o.banner          = 0
    o.cache_size      = 1000
    o.classic         = 0
    o.color_info      = 1
    o.confirm_exit  = 1
    o.debug = 0
    o.deep_reload = 0
    o.log = 0
    o.messages = 1
    o.pprint = 1
    o.prompt_in1 = '\C_DarkGray\Y1\C_Black [\C_DarkGray\N\C_Black]:\C_NoColor '
    o.prompt_in2 = '   .\D.: '
    o.prompt_out = '\C_White[\C_LightPurple\N\C_White] '
    o.prompts_pad_left = 1
    o.pylab_import_all = 1
    # o.readline = 1
    # o.screen_length = 0
    # o.separate_in = "\n"
    # o.separate_out = 0
    # o.separate_out2 = 0
    # o.wildcards_case_sensitive = 1
    # o.object_info_string_level = 0
    # o.xmode = "Context"
    # o.multi_line_specials = 1
    o.system_header = "IPython system call: "
    o.system_verbose = 1
    # o.wxversion = 0

    # import_mod 
    # import_some 
    
    #import_all("os sys")
    #execf('~/_ipython/ns.py')

    # Try one of these color settings if you can't read the text easily
    # autoexec is a list of IPython commands to execute on startup
    o.autoexec.append('%colors LightBG')
    #o.autoexec.append('%colors NoColor')
    #o.autoexec.append('%colors Linux')
    
    # for sane integer division that converts to float (1/2 == 0.5)
    #o.autoexec.append('from __future__ import division')
    
    # For %tasks and %kill
    #import jobctrl 
    
    # For autoreloading of modules (%autoreload, %aimport)    
    #import ipy_autoreload
    
    # For winpdb support (%wdb)
    #import ipy_winpdb
    
    # For bzr completer, requires bzrlib (the python installation of bzr)
    #ip.load('ipy_bzr')
    
    # Tab completer that is not quite so picky (i.e. 
    # "foo".<TAB> and str(2).<TAB> will work). Complete 
    # at your own risk!
    #import ipy_greedycompleter
    
    # If you are on Linux, you may be annoyed by
    # "Display all N possibilities? (y or n)" on tab completion,
    # as well as the paging through "more". Uncomment the following
    # lines to disable that behaviour
    # }}}
    import readline
    readline.parse_and_bind('set completion-query-items 1000')
    readline.parse_and_bind('set page-completions no')
    readline.parse_and_bind('tab complete ')
    readline.parse_and_bind('\C-l possible-completions')
    readline.parse_and_bind('set show-all-if-ambiguous on')
    readline.parse_and_bind('\C-o  tab-insert')
    readline.parse_and_bind('\M-i "    "')
    readline.parse_and_bind("\M-o \d\d\d\d")
    readline.parse_and_bind("\M-I \d\d\d\d")
    readline.parse_and_bind("\C-r reverse-search-history")
    readline.parse_and_bind("\C-s forward-search-history")
    readline.parse_and_bind("\C-p history-search-backward")
    readline.parse_and_bind("\C-n history-search-forward")
    readline.parse_and_bind("\e[A history-search-backward")
    readline.parse_and_bind("\e[B history-search-forward")
    readline.parse_and_bind("\C-k kill-line")
    readline.parse_and_bind("\C-u unix-line-discard ")
    o.readline_remove_delims = '-/~'
    o.readline_merge_completions = 1
    # o.readline.omit__names = 0

    print("IPYTHON: Finish ipy_user_conf.py")


# some config helper functions you can use 
def import_all(modules):
    """ Usage: import_all("os sys") """ 
    for m in modules.split():
        ip.ex("from %s import *" % m)

def execf(fname):
    """ Execute a file in user namespace """
    ip.ex('execfile("%s")' % os.path.expanduser(fname))

main()
