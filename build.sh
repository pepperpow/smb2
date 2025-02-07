#!/bin/sh

PRG0="47ba60fad332fdea5ae44b7979fe1ee78de1d316ee027fea2ad5fe3c0d86f25a"
PRG1="6ca47e9da206914730895e45fef4f7393e59772c1c80e9b9befc1a01d7ecf724"


compareHash() {
	echo $1 $2 | sha256sum --check > /dev/null 2>&1
}

build() {
	tools/asm6f smb2.asm bin/smb2.nes -l "$@" > bin/assembler.log
}

buildREV0() {
	tools/asm6f smb2_original.asm -l bin/smb2-orig.nes "$@" > bin/assembler.log
}

buildREVA() {
	tools/asm6f smb2_original.asm -dREV_A bin/smb2-reva.nes "$@" > bin/assembler.log
}

diffpatch() {
    tools/floating/flips-linux bin/smb2-orig.nes bin/smb2.nes bin/smb2-patch.ips --ips
    tools/floating/flips-linux bin/smb2-reva.nes bin/smb2.nes bin/smb2-patch-reva.ips --ips
}

if [ "$1" = "test" ] ; then

	buildErr=0

	buildREV0

	if [ $? -ne 0 ] ; then
		echo 'Failed building PRG0!'
		buildErr=1
	
	elif ! compareHash $PRG0 'bin/smb2-orig.nes' ; then
		echo 'PRG0 build did not match PRG0!'
		buildErr=1
	fi

	buildREVA

	if [ $? -ne 0 ] ; then
		echo 'Failed building PRG1!'
		buildErr=1

	elif ! compareHash $PRG1 'bin/smb2-reva.nes' ; then
		echo 'PRG1 build did not match PRG1!'
		buildErr=1
	fi

	if [ $buildErr -ne 0 ] ; then
		echo 'Test failed'
		exit $buildErr
	else
		echo 'Test passed: PRG0 and PRG1 built and matched original ROMs'
		exit $buildErr
	fi

fi

if [ "$1" = "diffpatch" ] ; then
	echo 'Assembling for patching...'
	build 
	if [ $? -ne 0 ] ; then
		echo 'Build failed!'
		exit 1
	fi
	echo 'Build succeeded.'
	diffpatch
	exit 0
fi

echo 'Assembling...'
build $@
if [ $? -ne 0 ] ; then
	echo 'Build failed!'
	exit 1
fi
echo 'Build succeeded.'

if compareHash $PRG0 'bin/smb2.nes' -eq 0 ; then
	echo 'Matched PRG0 ROM'
	exit 0
elif compareHash $PRG1 'bin/smb2.nes' -eq 0 ; then
	echo 'Matched PRG1 ROM'
	exit 0
else
	echo 'Did not match either ROM'
	exit -1
fi



