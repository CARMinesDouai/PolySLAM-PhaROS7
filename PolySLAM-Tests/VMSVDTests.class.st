Class {
	#name : #VMSVDTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMSVDTests >> matrix: matrixA isSimilarTo: matrixB [
	"returns true if the values of each cell are the same (+/- epsilon) between the two provided matrices"
	| error epsilon returnValue |
	
	returnValue := true.
	epsilon := 0.0001.
	
	1 to: 2 do: [ :r |
		1 to: 2 do: [ :c |
			error := (matrixA at: r at: c) - (matrixB at: r at: c).
			(error abs > epsilon) ifTrue: [
				returnValue := false.
			].
		].
	].
	
	^returnValue.

]

{ #category : #'as yet unclassified' }
VMSVDTests >> testMatrix [
	"computes the SVD for the matrix (1 2) / (0 1) and compares the results with pre-computed values"
	| m svd  epsilon u s v |
	
	epsilon := 0.000001.
	m := PMMatrix rows: { {1. 2}. {0. 1} }.
	u := PMMatrix rows: { {0.923879532. 0.382683432}. {-0.3826834324. 0.923879533} }.
	s := PMMatrix rows: { {2.41421356. 0}. {0. 0.414213562} }.
	v := PMMatrix rows: { {0.382683432. 0.923879533}. {-0.923879533. 0.3826834324} }.
	
	svd := VMSVD matrix: m.
	
	Transcript
		show: 'u='; cr;
		show: svd u; cr;
		show: 's='; cr;
		show: svd s; cr;
		show: 'v='; cr;
		show: svd v; cr.
	
	self assert: ( self matrix: svd u isSimilarTo: u ).
	self assert: ( self matrix: svd s isSimilarTo: s ).
	self assert: ( self matrix: svd v isSimilarTo: v ).

]

{ #category : #'as yet unclassified' }
VMSVDTests >> testMatrix2 [
	"computes the SVD for the matrix (1 2) / (0 1) and compares the results with pre-computed values"
	| m svd matR epsilon u s v |
	
	epsilon := 0.000001.
	m := PMMatrix rows: { {1. 2}. {0. 1} }.
	u := PMMatrix rows: { {0.923879532. -0.382683432}. {0.3826834324. 0.923879533} }.
	s := PMMatrix rows: { {2.41421356. 0}. {0. 0.414213562} }.
	v := PMMatrix rows: { {0.382683432. -0.923879533}. {0.923879533. 0.3826834324} }.
	
	svd := VMSVD2d matrix: m.
	
	Transcript
		show: 'u='; cr;
		show: svd u; cr;
		show: 's='; cr;
		show: svd s; cr;
		show: 'v='; cr;
		show: svd v; cr.
	
	matR := (svd v) * ((svd u) transpose).
	
	self assert: ( self matrix: matR isSimilarTo: (v * (u transpose) )).
	self assert: ( self matrix: svd s isSimilarTo: s ).
	
	" the following to asserts have been disabled, because the SVD matrices are not unique. instead we now test whether v * u^T is as expected.
	self assert: ( self matrix: svd u isSimilarTo: u ).
	self assert: ( self matrix: svd s isSimilarTo: s ).
	self assert: ( self matrix: svd v isSimilarTo: v ).
	"

]

{ #category : #'as yet unclassified' }
VMSVDTests >> testMatrix3 [
	"computes the SVD for the matrix (1 2) / (0 1) and compares the results with pre-computed values"
	| m svd matR epsilon u s v |
	
	epsilon := 0.001.
	m := PMMatrix rows: { {1. 0}. {2. 1} }.
	u := PMMatrix rows: { {0.3827. -0.9239}. {0.9239. 0.3827} }.
	s := PMMatrix rows: { {2.41421356. 0}. {0. 0.414213562} }.
	v := PMMatrix rows: { { 0.9239. -0.3827}. {0.3827. 0.9239} }.
	
	svd := VMSVD2d matrix: m.
	
	(((svd u) at: 1 at: 1) > 0) ifTrue: [
		u := u * -1.
		v := v * -1.
	].
	
	"
	Transcript
		show: 'u='; cr;
		show: svd u; cr;
		show: 's='; cr;
		show: svd s; cr;
		show: 'v='; cr;
		show: svd v; cr.
	"
	
	matR := (svd v) * ((svd u) transpose).
	
	self assert: ( self matrix: matR isSimilarTo: (v * (u transpose) )).
	self assert: ( self matrix: svd s isSimilarTo: s ).
	
	" the following to asserts have been disabled, because the SVD matrices are not unique. instead we now test whether v * u^T is as expected.
	self assert: ( self matrix: svd u isSimilarTo: u ).
	self assert: ( self matrix: svd v isSimilarTo: v ).
	"

]

{ #category : #'as yet unclassified' }
VMSVDTests >> testMatrix4 [
	"computes the SVD for the matrix (1 2) / (0 1) and compares the results with pre-computed values"
	| m svd  epsilon u s v |
	
	epsilon := 0.001.
	m := PMMatrix rows: { {35.02398748203447. 35.02398748203447}. {18.47485590899946. 18.47485590899946}}.
	u := PMMatrix rows: { {0.8844892518835475. -0.4665605676677813}. {0.4665605676677813. 0.8844892518835475} }.
	s := PMMatrix rows: { {55.9999999999999. 0}. {0. 0} }.
	v := PMMatrix rows: { {0.7071067811865475. -0.7071067811865475}. {0.7071067811865475. 0.7071067811865475} }.
	
	svd := VMSVD2d matrix: m.
	
	"(((svd u) at: 1 at: 1) > 0) ifTrue: [
		u := u * -1.
		v := v * -1.
	].
	"
	"
	Transcript
		show: 'u='; cr;
		show: svd u; cr;
		show: 's='; cr;
		show: svd s; cr;
		show: 'v='; cr;
		show: svd v; cr.
	"
	
	self assert: ( self matrix: svd u isSimilarTo: u ).
	self assert: ( self matrix: svd s isSimilarTo: s ).
	self assert: ( self matrix: svd v isSimilarTo: v ).

]

{ #category : #'as yet unclassified' }
VMSVDTests >> testMatrix5 [
	"matrix 'm' has been obtained from an experiment, the resulting SVD has been computed via Wolfram Alpha"
	| m svd  epsilon u s v |
	
	epsilon := 0.001.
	m := PMMatrix rows: { {45.23072026143753. -1.487678128764717}. {-0.9288670242711827. 152.7850195024504}}.
	u := PMMatrix rows: { {0.01264286705760862. 0.9999200757623399}. {-0.9999200757623399. 0.01264286705760862} }.
	s := PMMatrix rows: { {152.7989858570627. 0}. {0. 45.21754240280330} }.
	v := PMMatrix rows: { {0.009820999531184108. 0.9999517728211739}. {-0.9999517728211739. 0.009820999531184108} }.
	
	svd := VMSVD2d matrix: m.
	
	"(((svd u) at: 1 at: 1) > 0) ifTrue: [
		u := u * -1.
		v := v * -1.
	].
	"
	"
	Transcript
		show: 'u='; cr;
		show: svd u; cr;
		show: 's='; cr;
		show: svd s; cr;
		show: 'v='; cr;
		show: svd v; cr.
	"
	
	self assert: ( self matrix: svd u isSimilarTo: u ).
	self assert: ( self matrix: svd s isSimilarTo: s ).
	self assert: ( self matrix: svd v isSimilarTo: v ).

]

{ #category : #'as yet unclassified' }
VMSVDTests >> testMatrix6 [
	"matrix 'm' has been obtained from an experiment, the resulting SVD has been computed via Wolfram Alpha"
	| m svd matR epsilon u s v |
	
	epsilon := 0.001.
	m := PMMatrix rows: { {69.46896064256627. -109.23331996140627}. {-41.19869179115427. 141.94535382413517}}.
	u := PMMatrix rows: { {0.6568116097935055. -0.7540547123653985}. {-0.7540547123653985. -0.6568116097935055} }.
	s := PMMatrix rows: { {194.5362949102241. 0}. {0. 27.55540460078817} }.
	v := PMMatrix rows: { {0.3942405071204243. -0.9190073027704571}. {-0.9190073027704571. -0.3942405071204243} }.
	
	svd := VMSVD2d matrix: m.
	
	"(((svd u) at: 1 at: 1) > 0) ifTrue: [
		u := u * -1.
		v := v * -1.
	].
	"
	"
	Transcript
		show: 'u='; cr;
		show: svd u; cr;
		show: 's='; cr;
		show: svd s; cr;
		show: 'v='; cr;
		show: svd v; cr.
	"
	
	matR := (svd v) * ((svd u) transpose).
	
	self assert: ( self matrix: matR isSimilarTo: (v * (u transpose) )).
	self assert: ( self matrix: svd s isSimilarTo: s ).

]

{ #category : #'as yet unclassified' }
VMSVDTests >> testUV [
	"the matrices U and V of the SVD must satisify u*u^T = identity and v^T*v = identity. this test checks for these
	properties for a few symetric metrices. (symetric metrices are guaranteed to have real eigen values, which is
	required by our Eigen2d implementation)"
	| m mData svd  epsilon id |
	
	epsilon := 0.000001.
	
	mData := {
		{ {5. 2}.  {2. 1} }.
		{ {1. 0}.  {0. 1} }.
		{ {1024. 64}.  {64. 512} }.
	}.
	
	mData do: [ :data |
		m := PMMatrix rows: data.
		id := PMMatrix rows: { {1. 0}.  {0. 1} }.
		
		svd := VMSVD matrix: m.
		
		self assert: (
			self matrix: ((svd u transpose) * svd u) isSimilarTo: id 
		).
		
		self assert: (
			self matrix: ((svd v transpose) * svd v) isSimilarTo: id 
		).
	].

]

{ #category : #'as yet unclassified' }
VMSVDTests >> testUV2 [
	"the matrices U and V of the SVD must satisify u*u^T = identity and v^T*v = identity. this test checks for these
	properties for a few symetric metrices. (symetric metrices are guaranteed to have real eigen values, which is
	required by our Eigen2d implementation)"
	| m mData svd  epsilon id |
	
	epsilon := 0.000001.
	
	mData := {
		{ {5. 2}.  {2. 1} }.
		{ {1. 0}.  {0. 1} }.
		{ {1024. 64}.  {64. 512} }.
	}.
	
	mData do: [ :data |
		m := PMMatrix rows: data.
		id := PMMatrix rows: { {1. 0}.  {0. 1} }.
		
		svd := VMSVD2d matrix: m.
		
		self assert: (
			self matrix: ((svd u transpose) * svd u) isSimilarTo: id 
		).
		
		self assert: (
			self matrix: ((svd v transpose) * svd v) isSimilarTo: id 
		).
	].

]
