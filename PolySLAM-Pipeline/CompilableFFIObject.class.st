"
I am a compilable FFI object, i have C code in my class side, and compile this code to shared library if neccessary before accessing to this library using my instance side methods
"
Class {
	#name : #CompilableFFIObject,
	#superclass : #Object,
	#category : #'PolySLAM-Pipeline-Helper'
}

{ #category : #options }
CompilableFFIObject class >> arch [
	^Smalltalk vm wordSize = 8 ifTrue: [ '-m64' ] ifFalse: [ '-m32' ].
]

{ #category : #options }
CompilableFFIObject class >> cflags [
	^''
]

{ #category : #compiling }
CompilableFFIObject class >> compile [
	|files ofiles cmd paths st|
	files := self mksource.
	ofiles := files collect: [:file|self compileFile: file].
	"create shared object"
	paths := ofiles collect:[:e| '"',e pathString,'"'].
	cmd := 'gcc -shared ', self arch, ' -o "',self libPath pathString,'" ', (' ' join: paths), ' ', self ldflags.
	Transcript show: 'Building: ', cmd; cr.
	st := LibC system: cmd. 
	st = 0 ifFalse: [ ^self error:'Cannot create shared file: ', self libPath pathString ].
	files do:[:f| f delete].
	ofiles do:[:f| f delete].
]

{ #category : #compiling }
CompilableFFIObject class >> compileFile: fp [
	|ofile cmd st|
	ofile := fp parent / (fp basename, '.o').
	cmd := 'gcc -c -fpic ', self arch,' ',self cflags, ' "', fp pathString, '" -o "', ofile pathString, '"'.
	Transcript show: 'Building: ', cmd; cr.
	st := LibC system: cmd.
	st = 0 ifFalse: [ ^self error:'Cannot create object file for: ', fp pathString ].
	^ ofile
]

{ #category : #options }
CompilableFFIObject class >> ldflags [
	^''
]

{ #category : #options }
CompilableFFIObject class >> libBase [
	^Smalltalk vmDirectory asFileReference absolutePath asFileReference 
	"'./' asFileReference absolutePath"
]

{ #category : #options }
CompilableFFIObject class >> libName [
	^self subclassResponsibility 
]

{ #category : #options }
CompilableFFIObject class >> libPath [
	^self libBase / (self libName, '.ffi')
]

{ #category : #compilation }
CompilableFFIObject class >> mksource [
	|file stream i|
	i := 0.
	^self sources collect:[:e|
		file := (self libBase  /(self libName, i asString, '.c') ) asFileReference.
		file exists ifTrue:[ file delete ].
		stream := file writeStream.
		stream nextPutAll: e.
		stream close.
		i := i+1.
		file
	]
]

{ #category : #options }
CompilableFFIObject class >> sources [
	"should return a list of codes"
	^self subclassResponsibility 
]
