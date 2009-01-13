#!/bin/bash
# simple convert ps to pdf, so i dont have to remember options 
ps2pdf -dMaxSubsetPct=100 -dCompatibilityLevel=1.2 -dSubsetFonts=true -dEmbedAllFonts=true file.ps file.pdf 

# vim: ft=bash
