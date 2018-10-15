Class {
	#name : #VMPlotterStream,
	#superclass : #Object,
	#instVars : [
		'pid',
		'master'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #shell }
VMPlotterStream >> closeAndCleanStreams [
	self lib closept: self master.
	master := nil.
	pid := nil
]

{ #category : #accessing }
VMPlotterStream >> crlf [
	self nextPut: Character cr asString, Character lf asString
]

{ #category : #shell }
VMPlotterStream >> environ [
	|collection|
	collection := OrderedCollection new.
	Smalltalk os environment asDictionary keysAndValuesDo: [ :k :v|
		collection add: k,'=',v
	].
	^collection 
]

{ #category : #shell }
VMPlotterStream >> fileActionSettingFor:name [
	|st ptr|
	ptr := ExternalAddress allocate: self lib class sizeOfFileAction.
	st := self lib fileActionInit: ptr.
	st = 0 ifFalse:[^ self error:'Error posix_spawn_file_actions_init'].
	st := self lib fileActionAddOpen: ptr fd: 0  fileName: name  flag: self lib class O_RDWR  mode: 0644. 
	st = 0 ifFalse: [ ^ self error:'Error posix_spawn_file_actions_open' ].
	"st := self fileActionAddDup: ptr fd: 0  newFd: 0.
	st = 0 ifFalse: [ ^self error: 'Error posix_spawn_file_action_dup2' ]."
	"st := self lib fileActionAddDup: ptr fd: 0  newFd: 1.
	st = 0 ifFalse: [ ^self error: 'Error posix_spawn_file_action_dup2' ].
	st := self lib fileActionAddDup: ptr fd: 0  newFd: 2.
	st = 0 ifFalse: [ ^self error: 'Error posix_spawn_file_action_dup2' ]."
	^ ptr
]

{ #category : #accessing }
VMPlotterStream >> lib [
	^LibVMPlot singleton 
]

{ #category : #accessing }
VMPlotterStream >> master [
	^ master
]

{ #category : #shell }
VMPlotterStream >> next [ 
	|buff count data|
	buff := self lib getReadWriteBufferOf: 2048.
	count := self lib read: self master buffer: buff  size: 2048.
	data := ''.
	count > 0 ifTrue:[
		data :=  String newFrom: (FFIExternalArray fromHandle: buff type: 'char' size: count).
		self announcer announce: (PTermDataEvent data: data asByteArray ).
	].
	^data
]

{ #category : #shell }
VMPlotterStream >> nextPut: data [
	|buff |
	buff := ExternalAddress fromString: data.
	self lib write: self master buffer: buff  size: data size.
]

{ #category : #shell }
VMPlotterStream >> nextPutAll: text [
	|  subs|
	subs := text substrings: Character lf asString.
	subs do: [ :data|
		Transcript show:data.
		self nextPut: data, Character cr asString.
	 ].
]

{ #category : #accessing }
VMPlotterStream >> pid [
	^ pid
]

{ #category : #shell }
VMPlotterStream >> shellCommand:cmd [
	| status  fname fileaction xargv env|
	"spawn a subprocess"
	master := self lib master.
	status := FFIUInt32  newBuffer.
	xargv := (self lib stringArrayOf: cmd) getHandle.
	env := (self lib stringArrayOf: self environ ) getHandle.
	"self lib setNonBlocking: master." 
	fname := self lib ptsname: self master.
	fileaction  := self fileActionSettingFor:fname.
	self lib posixSpawn: status 
			process: (cmd at: 1)
			fileAction: fileaction
			fileAttr: nil
			argv: xargv
			env: env.
	pid := status integerAt: 1 size: 4 signed:true.
	fileaction free.
	^self
]

{ #category : #shell }
VMPlotterStream >> stdinStream [
	^self
]

{ #category : #shell }
VMPlotterStream >> waitForExit [
	|status|
	self pid ifNil: [ ^self ].
	status := FFIUInt32  newBuffer.
	"^self lib waitpid: self pid status: status  noHang: 0."
]
