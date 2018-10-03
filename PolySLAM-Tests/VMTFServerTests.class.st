Class {
	#name : #VMTFServerTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMTFServerTests >> testTransformations [
	"we are testing the access of frames and the concatination of the frames from parent to child"
	| server testFrame root childA childB childAA childBA collection epsilon |
	
	server := VMTFServer new.
	epsilon := 0.000001.
	
	root := (VMTransformationFrame position: 1@1 orientation: 0 id: 'root')
		linkWithParent: (server at: 'world');
		yourself..
	childA := (VMTransformationFrame position: 2@0 orientation: 0 id: 'childA')
		linkWithParent: root;
		yourself..
	childB := (VMTransformationFrame position: 2@0 orientation: Float pi id: 'childB')
		linkWithParent: root;
		yourself..
	childAA := (VMTransformationFrame position: 2@0 orientation: 0 id: 'childAA')
		linkWithParent: childA;
		yourself..
	childBA := (VMTransformationFrame position: 2@0 orientation: 0 id: 'childBA')
		linkWithParent: childB;
		yourself..
	
	collection := { root. childA. childB. childAA. childBA. }.
		
	server addAll: ( collection ).
	
	server print.
	collection do: [ :obj |
		Transcript show: obj printString; cr.
	].
	
	testFrame := server fromParent: 'root' toChild: 'childA'.
	self assert: ((testFrame position dist: (2@0)) < epsilon).
	Transcript show: testFrame printString; cr.

	testFrame := server fromParent: 'world' toChild: 'childA'.
	self assert: ((testFrame position dist: (3@1)) < epsilon).
	Transcript show: testFrame printString; cr.

	testFrame := server fromParent: 'world' toChild: 'childB'.
	self assert: ((testFrame position dist: (3@1)) < epsilon).
	Transcript show: testFrame printString; cr.

	testFrame := server fromParent: 'world' toChild: 'childBA'.
	self assert: ((testFrame position dist: (1@1)) < epsilon).
	Transcript show: testFrame printString; cr.

	testFrame := server fromParent: 'root' toChild: 'childBA'.
	self assert: ((testFrame position dist: (0@0)) < epsilon).
	Transcript show: testFrame printString; cr.




]
