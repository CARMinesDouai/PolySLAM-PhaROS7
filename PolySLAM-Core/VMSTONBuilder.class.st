"
This class is responsible for saving and loading class instances in the STON format. it provides default paths for convinience
"
Class {
	#name : #VMSTONBuilder,
	#superclass : #Object,
	#category : #'PolySLAM-Core-temp'
}

{ #category : #'as yet unclassified' }
VMSTONBuilder class >> load: filename [
	
	^self load: filename path: self path.

]

{ #category : #'as yet unclassified' }
VMSTONBuilder class >> load: filename path: path [
	| file handle data  obj |
	
	file := File named: path, filename.
	
	handle := file openForRead.
	
	data := handle upToEnd asString.
	
	handle close.
	
	obj := STON fromString: data.
	
	^obj.
]

{ #category : #'as yet unclassified' }
VMSTONBuilder class >> path [
	^'/opt/shared/developer/data/'.
]

{ #category : #'as yet unclassified' }
VMSTONBuilder class >> save: anObj filename: filename [
	self save: anObj filename: filename path: self path.
]

{ #category : #'as yet unclassified' }
VMSTONBuilder class >> save: anObj filename: filename path: path [
	| file handle |
	
	file := File named: path, filename.
	
	handle := file openForWrite.
	
	handle truncate;
		nextPutAll:(STON toString: anObj);
		close.
	

]

{ #category : #'as yet unclassified' }
VMSTONBuilder class >> save: anObj prefix: prefix [
	| className extension |
	className := anObj class name.
	extension := '.ston'.
	
	self save: anObj filename: prefix, className, extension path: self path.
]
