Class {
	#name : #VMTransformationFrameTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMTransformationFrameTests >> testFrameInverse [
	| root child inv epsilon invFrame |
	
	epsilon := 0.0000001.
	
	root := (VMTransformationFrame new)
		position: 2@3;
		orientation: Float pi / 2.5.
	
	child := (VMTransformationFrame new)
		position: -2@1;
		orientation: Float pi / 1.5.
	
	child linkWithParent: root.
	
	inv := child inverse.
	inv linkWithParent: child.
	
	invFrame := inv frame.
	"infFrame should be position=0@0, orientation=0.0"
	self assert: ( (invFrame position dist: 0@0) < epsilon ).
	self assert: ( invFrame orientation < epsilon and: [ invFrame orientation > (epsilon negated) ]).
	
	"
	Transcript
		show: 'root inv ', root inverse printString;
		cr;
		show: 'child inv ', child inverse printString;
		cr;
		show: 'child frame ', child frame printString;
		cr;
		show: 'inv frame ', inv frame printString;
		cr.
	"
	



]

{ #category : #'as yet unclassified' }
VMTransformationFrameTests >> testFrameTree [
	| epsilon root childA childB grandChildB1 grandChildB2 |
	
	epsilon := 0.00000001.
	
	root := (VMTransformationFrame new)
		id: 'root';
		position: 1@2;
		orientation: 0.
	
	childA := (VMTransformationFrame new)
		id: 'A';
		position: 3.3@1.1;
		orientation: Float pi.
		
	childB := (VMTransformationFrame new)
		id: 'B';
		position: 0@1;
		orientation: Float halfPi.
		
	grandChildB1 := (VMTransformationFrame new)
		id: 'B1';
		position: 1@1;
		orientation: 0.
	
	grandChildB2 := (VMTransformationFrame new)
		id: 'B2';
		position: 1@0;
		orientation: 0.
		
	
	childA linkWithParent: root.
	childB linkWithParent: root.
	grandChildB1 linkWithParent: childB.
	grandChildB2 linkWithParent: childB.
	
	self assert: ( (root frame position dist: root position) < epsilon ).
	self assert: ( (childA frame position dist: 4.3@3.1) < epsilon ).
	self assert: ( (childB frame position dist: 1@3) < epsilon ).
	self assert: ( (grandChildB1 frame position dist: 2@2) < epsilon ).
	self assert: ( (grandChildB2 frame position dist: 1@2) < epsilon ).
	
	"Transcript
		show: 'root ', root frame printString;
		cr;
		show: 'childA ', childA frame printString;
		cr;
		show: 'childB ', childB frame printString;
		cr;
		show: 'grandChildB1 ', grandChildB1 frame printString;
		cr;
		show: 'grandChildB2 ', grandChildB2 frame printString;
		cr.
		"
	

]
