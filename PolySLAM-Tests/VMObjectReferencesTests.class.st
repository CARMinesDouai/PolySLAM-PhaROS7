Class {
	#name : #VMObjectReferencesTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMObjectReferencesTests >> testAtPut [
	| keys values expectedSizes |
	
	keys := { 'a'.  'b'.  'c'.  'd'. }.
	values := { 1.  2.  3.  4.  5. }.
	expectedSizes := { 5.  4.  3.  2. }.
	
	keys doWithIndex: [ :key :index |
		1 to: (values size - index + 1) do: [ :index2 |
			VMObjectReferences at: key put: (values at: index2).
		]
	].
	
	"check the sizes"
	keys doWithIndex: [ :key :index |
		self assert: (VMObjectReferences at: key) size equals: (expectedSizes at: index).
	].
	
	"check two 'random' elements"
	self assert: ((VMObjectReferences at: keys second) includes: values fourth).
	self assert: ((VMObjectReferences at: keys third) includes: values fourth) not.
	
]
