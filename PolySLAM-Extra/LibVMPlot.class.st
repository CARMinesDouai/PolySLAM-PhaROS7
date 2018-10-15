Class {
	#name : #LibVMPlot,
	#superclass : #FFILibrary,
	#classInstVars : [
		'instance'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #'C-constants' }
LibVMPlot class >> F_GETFL [
	^3
]

{ #category : #'C-constants' }
LibVMPlot class >> F_SETFL [
	^4
]

{ #category : #'C-constants' }
LibVMPlot class >> O_NONBLOCK [
	Smalltalk os isMacOS ifTrue: [ ^4 ].
	^4000
]

{ #category : #'C-constants' }
LibVMPlot class >> O_RDWR [
	^2
]

{ #category : #'C-constants' }
LibVMPlot class >> SIGKILL [
	^ 9
]

{ #category : #'C-constants' }
LibVMPlot class >> ST_WINSIZE [
	^8
]

{ #category : #'C-constants' }
LibVMPlot class >> TIOCGWINSZ [
	Smalltalk os isMacOS ifTrue: [ ^1074295912 ].
	^21523
]

{ #category : #'C-constants' }
LibVMPlot class >> TIOCSWINSZ [
	Smalltalk os isMacOS ifTrue: [ ^2148037735 ].
	^21524
]

{ #category : #'instance creation' }
LibVMPlot class >> new [
	self error: 'Please use #singleton'
]

{ #category : #'instance creation' }
LibVMPlot class >> singleton [ 
	^ self uniqueInstance 
]

{ #category : #'C-constants' }
LibVMPlot class >> sizeOfFileAction [
	"we fix it to 80 for now"
	^80
]

{ #category : #lib }
LibVMPlot >> closept: fd [
	^ self ffiCall: #(int close(int fd)) module: LibC
]

{ #category : #'instance creation' }
LibVMPlot >> exec: command [
	^ LibC uniqueInstance system: command
]

{ #category : #lib }
LibVMPlot >> fileActionAddDup: pointer fd: fd newFd: fd2 [ 
	^self ffiCall: #(int posix_spawn_file_actions_adddup2( void* pointer, int fd, int fd2)) module: LibC.
]

{ #category : #lib }
LibVMPlot >> fileActionAddOpen: pointer fd: fd fileName: name flag: flag mode: mode [ 
	^self ffiCall: #(int posix_spawn_file_actions_addopen( void* pointer, int fd, char* name, int flag, int mode )) module: LibC.
]

{ #category : #lib }
LibVMPlot >> fileActionInit: pointer [
	^self ffiCall: #(int posix_spawn_file_actions_init( void* pointer )) module: LibC.
]

{ #category : #lib }
LibVMPlot >> fnctl: fd action: action flag: flag [
 	^ self ffiCall: #(int fcntl(int fd, int action, int flag)) module: LibC 
]

{ #category : #writing }
LibVMPlot >> getReadWriteBufferOf: size [
	^(FFIExternalArray externalNewType: 'char' size: size) getHandle
]

{ #category : #lib }
LibVMPlot >> grantpt: fd [
	^ self ffiCall: #(int grantpt(int fd)) module: LibC
]

{ #category : #accessing }
LibVMPlot >> kill: pid signal: sig [
	^ self ffiCall: #(int kill(int pid, int sig)) module: LibC
]

{ #category : #accessing }
LibVMPlot >> master [
	|fd st|
	fd := self openpt: (self class O_RDWR bitOr: self class O_NONBLOCK).
	fd < 0 ifTrue:[^self error:'Error on on posix_openpt()'].
	st := self grantpt: fd.
	st ~= 0 ifTrue: [ self closept: fd. ^ self error: 'Error on grantpt()' ].
	st := self unlockpt: fd.
	st ~= 0 ifTrue: [ self closept: fd. ^ self error: 'Error on unlockpt()' ].
	^fd
	
]

{ #category : #lib }
LibVMPlot >> open: name mode: flag [
	^ self ffiCall: #(int open(char* name, int flag)) module: LibC
]

{ #category : #lib }
LibVMPlot >> openpt: flag [
	^ self ffiCall: #(int posix_openpt(int flag)) module: LibC
]

{ #category : #lib }
LibVMPlot >> posixSpawn:pid  process: cmd fileAction: ptr fileAttr:fattr argv: args env: envs [
	^ self ffiCall:#( int posix_spawnp(int* pid, char* cmd, void* ptr, void* fattr, void* args, void* envs ))  module: LibC  
]

{ #category : #lib }
LibVMPlot >> ptsname: fd [
	^ self ffiCall: #(char* ptsname(int fd)) module: LibC
]

{ #category : #lib }
LibVMPlot >> read: fd buffer: buff size: size [
	^self ffiCall: #(int read(int fd, char* buff, int size)) module: LibC 
]

{ #category : #lib }
LibVMPlot >> stringArrayOf: anArray [
	|xarray|
	anArray  ifNil: [ ^nil ].
	xarray := FFIExternalArray externalNewType: 'char*' size: anArray size + 1. 
	anArray withIndexDo: [ :v :i| xarray at:i put: (ExternalAddress fromString: v) ]. 
	xarray at:anArray size + 1 put: (ExternalAddress  fromAddress: 0).
	^ xarray 
]

{ #category : #lib }
LibVMPlot >> unlockpt: fd [
	^ self ffiCall: #(int unlockpt(int fd)) module: LibC
]

{ #category : #lib }
LibVMPlot >> waitpid: pid status: buf noHang: v [
	^ self ffiCall: #(int waitpid(int pid, int * buf, int v)) module: LibC
]

{ #category : #writing }
LibVMPlot >> write: fd buffer: buff size: size [
	^self ffiCall: #(int write(int fd, char* buff, int size)) module: LibC 
]
