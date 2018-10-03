Class {
	#name : #VMLineSegReferences,
	#superclass : #Dictionary,
	#classVars : [
		'UniqueInstance'
	],
	#category : #'PolySLAM-Core-temp'
}

{ #category : #accessing }
VMLineSegReferences class >> at: objectA [

	^(self singelton) at: objectA
]

{ #category : #accessing }
VMLineSegReferences class >> at: objectA put: objectB [

	"self logCr: '  add: ', objectA printString, ' --> ', objectB printString."
	^(self singelton) at: objectA put: objectB
	
]

{ #category : #'as yet unclassified' }
VMLineSegReferences class >> logN: aNumber [
	"prints the first 'aNumber' key/value pairs to the Transcript console"
	| ref size max keys |
	
	ref := self singelton.
	size := ref size.
	keys := ref keys.
	
	ref rehash.
	
	Transcript show: self printString, ' (', size printString, ' elements)'; cr.
	max := aNumber min: size.
	1 to: max do: [ :index |
		| value |
		value := ref at: (keys at: index).
		Transcript show: '  ', (keys at: index) printString, ' --> ', value printString; cr.
	].
	size > max ifTrue: [
		Transcript show: '  and ', (size - max) printString, ' more'; cr.
	].

]

{ #category : #'as yet unclassified' }
VMLineSegReferences class >> resetSingelton [
	UniqueInstance := nil
]

{ #category : #'as yet unclassified' }
VMLineSegReferences class >> singelton [
	UniqueInstance ifNil: [UniqueInstance := self new.].

	^UniqueInstance
]
