Class {
	#name : #VMEigen2dTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMEigen2dTests >> testMatrix [
	| m eigen error epsilon |
	
	epsilon := 0.000001.
	m := DhbMatrix rows: 2 columns: 2.
	m at: 1 at: 1 put: 1.
	m at: 1 at: 2 put: 2.
	m at: 2 at: 1 put: 0.
	m at: 2 at: 2 put: 1.
	
	eigen := VMEigen2d matrix: m.
	
	"Transcript
		show:
			'vec1=', eigen vector1 printString,
			', vec2=', eigen vector2 printString,
			', value1=', eigen value1 printString,
			', value2=', eigen value2 printString;
		cr.
	"
	error := eigen value1 - 1.0.
	self assert: (error abs < epsilon).
	
	error := eigen value2 - 1.0.
	self assert: (error abs < epsilon).
	
	error := eigen vector1 normalized dist: (1@0).
	self assert: (error abs < epsilon).
	
	error := eigen vector2 normalized dist: (1@0).
	self assert: (error abs < epsilon).
	

]

{ #category : #'as yet unclassified' }
VMEigen2dTests >> testMatrix2 [
	| m phi eigen error epsilon |
	
	epsilon := 0.000001.
	phi := Float pi * 0.25.
	m := DhbMatrix rows: 2 columns: 2.
	m at: 1 at: 1 put: (phi cos).
	m at: 1 at: 2 put: (phi sin negated).
	m at: 2 at: 1 put: (phi sin).
	m at: 2 at: 2 put: (phi cos).
	
	eigen := VMEigen2d matrix: (m transpose * m).
	
	"Transcript
		show:
			'vec1=', eigen vector1 printString,
			', vec2=', eigen vector2 printString,
			', value1=', eigen value1 printString,
			', value2=', eigen value2 printString;
		cr.
	"
	error := eigen value1 - 1.0.
	self assert: (error abs < epsilon).
	
	error := eigen value2 - 1.0.
	self assert: (error abs < epsilon).
	
	"note: if the test fails, check first if the order of the vectors is just the other way around"
	error := eigen vector1 normalized dist: (1@0).
	self assert: (error abs < epsilon).
	
	error := eigen vector2 normalized dist: (0@1).
	self assert: (error abs < epsilon).
	

]

{ #category : #'as yet unclassified' }
VMEigen2dTests >> testMatrix3 [
	| m eigen error epsilon |
	
	epsilon := 0.0001.
	m := DhbMatrix rows: 2 columns: 2.
	m at: 1 at: 1 put: 5.
	m at: 1 at: 2 put: 2.
	m at: 2 at: 1 put: 2.
	m at: 2 at: 2 put: 1.
	
	eigen := VMEigen2d matrix: m.
	
	"Transcript
		show: eigen printString;
		cr.
	"
	error := eigen value1 - 5.8284271.
	self assert: (error abs < epsilon).
	
	error := eigen value2 - 0.1715729.
	self assert: (error abs < epsilon).
	
	error := eigen vector1 normalized dist: (0.923879532@0.382683432).
	self assert: (error abs < epsilon).
	
	error := eigen vector2 normalized dist: (-0.3826834324@0.923879532).
	self assert: (error abs < epsilon).
	

]
