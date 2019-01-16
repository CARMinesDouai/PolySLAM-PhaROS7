Class {
	#name : #VMDemosExamples,
	#superclass : #Object,
	#category : #'PolySLAM-Extra-Examples'
}

{ #category : #examples }
VMDemosExamples class >> exampleBSPTree [
	| polygons root viewer |
	
	polygons := VMDataSet toyExample_polygons.

	root := VMBSPLeaf new.
	
	root := root insert: polygons first.
	root := root insert: polygons second.
	root := root insert: polygons third.
	root := root insert: polygons fourth.
	
	"viewer := (VMViewer openOn: { polygons asVMPolygonCollection })
		backgroundColor: Color gray;
		autozoom.
	"
	
	viewer := (VMViewer openOn: { root })
		backgroundColor: Color gray;
		autozoom.
	

]

{ #category : #examples }
VMDemosExamples class >> exampleICPVisualisation [
	| data data2 icp renderICP |
	data := {  -3 @ -3.  -2 @ -2.  -1 @ -1.  0@0. 1@1.  2@2.  3@3.  }.
	
	data2 := data collect: [ :p |  p rotateBy: 0.3 about: 0@0  ].
	
	icp := VMICP_old new.
	icp alignPointCollection: data2 with: data.
	renderICP := icp asRenderableElement.
	
	(VMMapViewer openOn: { renderICP. }
		extent: 1000@800)
		zoomFactor: 60 at: 0@0;
		panTo: 490@370.
	

]

{ #category : #examples }
VMDemosExamples class >> exampleICPVisualisation2 [
	| data data2 icp renderICP |
	data := {  -3 @ -3.  -2 @ -2.  -1 @ -1.  0@0. 1@1.  2@2.  3@3.  }.
	
	data2 := data collect: [ :p |  p rotateBy: 0.3 about: 0@0  ].
	
	icp := VMICP_old new.
	icp alignPointCollection: data2 with: data.
	renderICP := icp asRenderableElement.
	
	(VMMapViewer openOn: { renderICP. }
		extent: 1000@800)
		zoomFactor: 60 at: 0@0;
		panTo: 490@370.
	
	icp iterateOnce.

]

{ #category : #examples }
VMDemosExamples class >> exampleICPVisualisation3 [
	| data data2 icp renderICP rC rC2 |
	data := {
		1@ -2.  2@ -1.  3@0.  4@1.  4@2.  4@3.  3@3.  2@3.  1@3.
		1@4.  1@5.  1@6.  1@7.  1@8.  2@9.  3@10.
		4@10. 5@10.  7@10.
	}.
	
	data2 := data collect: [ :p |
		(p rotateBy: 0.3 about: 3.5@3.5) + (0.1@0.133)
	].
	
	icp := VMICP_old new.
	icp alignPointCollection: data2 with: data.
	rC := VMPointRendererOld model: (icp computeCentroid: data).
	rC2 := VMPointRendererOld model: (icp computeCentroid: data2).
	renderICP := icp asRenderableElement.
	
	rC color: (Color red).
	rC2 color: (Color blue).
	
	(VMMapViewer openOn: { renderICP. rC. rC2. }
		extent: 1000@800)
		zoomFactor: 60 at: 0@0;
		panTo: 350@90.
	
	icp iterateOnce.
	

]

{ #category : #deprecated }
VMDemosExamples class >> exampleMap1 [
	| map |
	map := VMMapFactory fromData: VMDataSet dataMap_1.
	map := map asRenderableElement 
				textScale: 0.15.
	
	(VMMapViewer openOn: {map}) 
		zoomFactor: 9 at: 0@0;
		panTo: 230@140
		
]

{ #category : #deprecated }
VMDemosExamples class >> exampleMap2 [
	| map |
	map := VMMapFactory fromData: VMDataSet dataMap_2.
	
	map := map asRenderableElement 
				textScale: 0.05.
				
	(VMMapViewer openOn: {map} extent: 1000@700) 
		zoomFactor: 22 at: 0@0;
		panTo: 130@191
		
]

{ #category : #deprecated }
VMDemosExamples class >> exampleMap3 [
	| map |
	map := VMMapFactory fromData: VMDataSet dataMap_3.
	
	map := map asRenderableElement textScale: 0.1.
	map visGraphRenderer lineWidth: 0.05.
				
	(VMMapViewer openOn: {map} extent: 800@800) 
		zoomFactor: 18 at: 0@0;
		panTo: 136@137
		
	
]

{ #category : #deprecated }
VMDemosExamples class >> exampleMap4 [
	| map |
	map := VMMapFactory fromData: VMDataSet dataMap_4.
	
	map := map asRenderableElement 
				showVertices: true;
				textScale: 0.1;
				textColor: Color white.
	
	(VMMapViewer openOn: {map} extent: 1000@700) 
		zoomFactor: 17 at: 0@0;
		panTo: 160@98
		
	
]

{ #category : #deprecated }
VMDemosExamples class >> exampleMap5 [
	| map |
	map := VMMapFactory fromData: VMDataSet dataMap_8.
	map := map asRenderableElement 
				textScale: 0.02.
	
	(VMMapViewer openOn: {map}) 
		zoomFactor: 35 at: 0@0;
		panTo: 270@230
		
]

{ #category : #examples }
VMDemosExamples class >> exampleMapViewer [
	(VMMapViewer openOn: [ :can |  
		can pathTransform translateX: 30 Y: 30.
		can pathTransform rotateByDegrees: 35.
		can setPaint: Color red.
			
		can setShape: (-20@ -20 corner: 20@ 20).
			2 timesRepeat: [ can draw. can setPaint: (Color blue alpha:0.5)].
	]) panTo: 263@243
]

{ #category : #broken }
VMDemosExamples class >> examplePathSearch [
	
	| elements searchPathNode pathRenderer elem |
	elements := {
		VMMapFactory fromData: VMDataSet dataMap_6.
		VMIsolatedPoint fromPoint: (-3@ -8) id: 'start'.
		VMIsolatedPoint fromPoint: (3@ -8) id: 'goal'.
	} asOrderedCollection.

	elements first visGraph 
		addPolygon: elements second; 
		addPolygon: elements third.

	searchPathNode := VMPathSearch
		compute: elements first visGraph
		from: elements second vertex
		to: elements third vertex.
	
	pathRenderer := VMSegmentRenderer new
		color: Color orange;
		lineWidth: 0.2.
	
	elem := searchPathNode.
	[ elem prev ] whileNotNil: [ 
		elements add: (
			pathRenderer copy
				model: ( VMLineSegment from: elem vertex point to: elem prev vertex point );
				yourself
		).
		elem := elem prev
	].
	
	elements at: 1 put: (elements first asRenderableElement).
	elements first textScale: 0.1.
		
	(VMMapViewer openOn: elements extent: 700@700) 
		zoomFactor: 27 at: 0@0;
		panTo: 320@351
	
]

{ #category : #deprecated }
VMDemosExamples class >> examplePolygonExpand [
	
	| elements polygon |
	elements := OrderedCollection new.
	
	elements add: ((VMClosedPolygon fromOrderedPoints: { 10@10.  30@10. 20@20 }) asRenderableElement color: Color blue).
	
	polygon := elements first model.
	
	(1 to: polygon vertices size-1) do: [ :i |
		elements add: ((polygon
			getExpandLineSeg: 5
			from: (polygon vertices at: i)
			to: (polygon vertices at: i+1)) asRenderableElement color: Color cyan; lineWidth: 0.1)
	].
	elements add: ((polygon
		getExpandLineSeg: 5
		from: polygon vertices last
		to: polygon vertices first) asRenderableElement color: Color cyan; lineWidth: 0.1).
	
	elements add: ((VMGraphVertex point: ((polygon vertices at: 1) +
		(polygon
			getExpandVec: 5
			prev: (polygon vertices at: 3)
			current: (polygon vertices at: 1)
			next: (polygon vertices at: 2))
		)) asRenderableElement color: Color cyan; showLabel: false).
	
	elements add: ((polygon getExpandCapLine: 5
		prev: (polygon vertices at: 3)
		current: (polygon vertices at: 1)
		next: (polygon vertices at: 2)) asRenderableElement color: Color yellow).
	
	elements add: ((polygon expand: 5) asRenderableElement solid: false; color: Color red)  after: elements first.
		
	(VMMapViewer openOn: elements) 
		zoomFactor: 15.5 at: 0@0;
		panTo: -20@93

]

{ #category : #deprecated }
VMDemosExamples class >> examplePolygonExpand2 [
	| polygon polygonEx |
	
	polygon := VMClosedPolygon fromOrderedPoints: { 10@10.  50@20. 10@30. 40@20 }.
	polygon makeCW.
	
	polygonEx := (polygon expand: 5) asRenderableElement solid: false; color: Color red.
	polygon := polygon asRenderableElement color: Color blue.
	
	
	(VMMapViewer openOn: {polygon . polygonEx}) 
		zoomFactor: 4.5 at: 0@0;
		panTo: -25@251

]

{ #category : #deprecated }
VMDemosExamples class >> examplePolygonExpand3 [
	
	| polygon polygonEx |
	polygon := VMClosedPolygon fromOrderedPoints: { 10@10. 70@25. 10@40. 42@25 }.
	polygon makeCW.
	polygon setVerticesIds.
	
	polygonEx := polygon expand: 30.
	polygonEx setVerticesIds.

	
	polygon := polygon asRenderableElement 
						color: Color blue; 
						showVertices: true;
						textScale: 0.6.
						
	polygonEx := polygonEx asRenderableElement
						solid: false; 
						color: Color red.
	
	(VMMapViewer openOn: {polygon . polygonEx} extent: 1200@700)
		zoomFactor: 3.2 at: 0@0;
		panTo: 196@268

]

{ #category : #deprecated }
VMDemosExamples class >> examplePolygons [
	| polygons colors |
	
	colors := { Color blue. Color red. Color magenta. Color cyan }.
	
	polygons := (1 to: 4) collect: [ :i | 
		(VMDataSet dataPolygon_1 
			move: (5*i)@(5*i) ) asRenderableElement 
			color: (colors at: i)
	].
		
	(polygons first solid: true) 
		model makeCW.
	
	polygons second showVertices: true.
	polygons third beDashed.
	
	(VMMapViewer openOn: polygons) 
		zoomFactor: 8 at: 0@0;
		panTo: 4@36
]

{ #category : #deprecated }
VMDemosExamples class >> examplePolygons2 [
	| boundary polygons colors positions |
	
	boundary := VMClosedPolygon fromOrderedPoints: { -80@ -80. 80@ -80. 80@80. -80@80. }.
	boundary makeCW.
	
	colors := { Color blue. Color red }.
	positions := { 20@20. -60@ -60 }.
	
	polygons := (1 to: 2) collect: [ :i | 
		(VMDataSet dataPolygon_1 
			move: (positions at: i) )
				asRenderableElement 
					color: (colors at: i)
	].
	polygons := polygons asOrderedCollection.
	
	polygons second 
		showVertices: true ;
		textScale: 0.8.
	polygons addFirst: (boundary asRenderableElement solid: true).
	
	(VMMapViewer openOn: polygons) 
		zoomFactor: 3 at: 0@0;
		panTo: 293@298

]

{ #category : #deprecated }
VMDemosExamples class >> examplePolygons3 [
	
	| polygons |
	
	polygons := OrderedCollection new.	
	(polygons add: (VMClosedPolygon fromOrderedPoints: { -80@ -80. 80@ -80. 80@80. -80@80 })) makeCW.
	(polygons add: VMDataSet dataPolygon_1bis) makeCCW.
	(polygons add: VMDataSet dataPolygon_5) move: -10@10.
	
	polygons := polygons collect: #asRenderableElement.
	polygons first color: Color blue.
	polygons second color: Color blue; showVertices: true.
	polygons third color: Color cyan; showVertices: true.
	
	(VMMapViewer openOn: polygons) 
		zoomFactor: 3 at: 0@0;
		panTo: 293@298

]

{ #category : #deprecated }
VMDemosExamples class >> examplePolygons4 [
	| polygons |
	
	polygons := OrderedCollection new.	
	(polygons add: (VMClosedPolygon fromOrderedPoints: { -80@ -80. 80@ -80. 80@80. -80@80 })) makeCW.
	(polygons add: (VMClosedPolygon fromOrderedPoints: { -5@0. 50@0. 50@50. -5@50 })) makeCCW.
	(polygons add: (VMClosedPolygon fromOrderedPoints: { 0@20. 40@ -40. -50@30 })) makeCCW.
	polygons add: (polygons second merge: {polygons third}).
	
	polygons := polygons collect: #asRenderableElement.
	polygons second color: Color blue; showVertices: true.
	polygons third color: Color cyan; showVertices: true.
	polygons fourth color: Color red; solid: false;  showVertices: true; beDashed.
	
	(VMMapViewer openOn: polygons) 
		zoomFactor: 3 at: 0@0;
		panTo: 293@298
]

{ #category : #examples }
VMDemosExamples class >> exampleSegmentIntersection [

	| colors allRenderableElements segments |
	
	allRenderableElements := OrderedCollection new.
	
	segments := OrderedCollection new.
	segments 
		add: (VMLineSegment from: ((-60@ -50) asVMVertex id: 'A') to: ((60@60) asVMVertex id: 'B'));
		add: (VMLineSegment from: -50@ -10 to: 50@ -10);
	 	add: (VMLineSegment from: 60@ -40 to: -40@40).
		
	colors := { Color blue . Color red. Color green. }.
		
	segments doWithIndex: [ :seg :i |
		allRenderableElements add: (
			seg asRenderableElement 
				beDashed ;
				color: (colors at: i);
				label: '#',i asString;
				lineWidth: 0.5
		).
		
		segments from: i+1 to: segments size do: [ :s |
			seg ifIntersectsWith: s do: [ :p :f |
				allRenderableElements add: ( 
					(VMGraphVertex point: p id: (i asString, ' (',(f round: 2) asString,')')) asRenderableElement 
						color: Color yellow 
				)
			]	
		]
	].
	
	(VMMapViewer openOn: allRenderableElements) 
		zoomFactor: 4 at: 0@0;
		panTo: 299@287
	
	
]

{ #category : #broken }
VMDemosExamples class >> exampleSimulator1 [
	"a small example that places a robot with a single laser range finder in a small map"
	| map renderMap robot renderRobot sensor |
		
	map := VMMapFactory fromData: VMDataSet dataMap_1.
	
	renderMap := map asRenderableElement
		textScale: 0.15.
	
	
	robot := (VMRobot new)
		map: map;
		radius: 0.3;
		orientation: Float pi / 3 * 0;
		speed: 0.2@0.1;
		position: 0.5@0.
		
	renderRobot := (robot asRenderableElement)	
		lineWidth: 0.05.
	
	
	sensor := (VMSensorLRF new)
		angle: (Float pi / 1.3);
		maxRange: 20.0;
		rayCount: 15.
	robot addSensor: sensor.
	
	
	(VMMapViewer openOn: { renderMap.  renderRobot }) 
		zoomFactor: 9 at: 0@0;
		panTo: 230@140.
	
	
	robot spinOnce.


]

{ #category : #broken }
VMDemosExamples class >> exampleSimulator2 [
	| map renderMap robot renderRobot sensor sim renderCollection |
	
	VMTFServer singleton reset.

	map := VMMapFactory fromData: VMDataSet dataMap_8.
	map visGraph: nil.
	renderMap := map asRenderableElement
		textScale: 0.01;
		lineWidth: 0.05.

	robot := (VMRobot id: 'robo')
		map: map;
		radius: 0.22;
		orientation: Float pi * 1.1;
		speed: 0.2@0.1;
		position: -2@0.
	renderRobot := (robot asRenderableElement)
		lineWidth: 0.05.

	sensor := (VMSensorLRF id: 'lrf')
		angle: (Float pi / 1.3);
		maxRange: 10.0;
		rayCount: 30.
	robot addSensor: sensor.

	robot tf register.
	sensor tf register.

	sim := (VMSimulator new)
		map: map;
		objects: {robot}.

	sim spinOnce.

	renderCollection := { renderMap.  renderRobot } asOrderedCollection.

	(VMMapViewer openOn: renderCollection extent: 1000@800)
		zoomFactor: 60 at: 0@0;
		panTo: 400@280.
		
	

]

{ #category : #examples }
VMDemosExamples class >> exampleTopologicalGraph [
	|polygons root builder graph |
	polygons := VMDataSet toyExample_polygons_ICIRA.
	
	
	root := VMBSPLeaf new.
	polygons do: [ :p | root := root insert: p ].
	
	
	builder := VMGraphBuilderOld new.
	
	graph := builder buildGraphFromBSPTree: root.
	
	(VMViewer openOn: { VMGridRenderer new.  root.  graph. })
		autozoom.


]

{ #category : #examples }
VMDemosExamples class >> exampleTrajectory [
	| map renderMap robot renderRobot sensor sim renderCollection trajectory |
	VMTFServer singleton reset.


	map := VMMapFactory fromData: VMDataSet dataMap_8.
	map visGraph: nil.
	renderMap := map asRenderableElement
		textScale: 0.01;
		lineWidth: 0.05.


	robot := (VMRobot id: 'robo')
		map: map;
		radius: 0.22;
		orientation: Float pi * 1.1;
		speed: 0.2@ -0.01;
		position: -2@0.
	renderRobot := (robot asRenderableElement)
		lineWidth: 0.05.


	sensor := (VMSensorLRF id: 'lrf')
		angle: (Float pi / 1.3);
		maxRange: 10.0;
		rayCount: 30.
	robot addSensor: sensor.



	robot tf register.
	sensor tf register.



	"sensor spinOnce."



	sim := (VMSimulator new)
		map: map;
		objects: {robot}.

	sim spinOnce.

	renderCollection := { renderMap.  renderRobot } asOrderedCollection.


	(VMMapViewer openOn: renderCollection extent: 1000@800)
		zoomFactor: 60 at: 0@0;
		panTo: 400@280.





	trajectory := VMTrajectory new.

	1 to: 5 do: [ :i |
		trajectory
			add: (VMLocation
				frame: robot tf frame
				timestamp: VMTimestamp new).
		
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
	].


	(VMMapViewer openOn: {trajectory asRenderableElement} extent: 1000@800)
		zoomFactor: 60 at: 0@0;
		panTo: 400@280.


	robot speed: (0.3@0.0).
	1 to: 8 do: [ :i |
		trajectory
			add: (VMLocation
				frame: robot tf frame
				timestamp: VMTimestamp new).
		
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
	].


	robot speed: (0.4@0.0).
	1 to: 6 do: [ :i |
		trajectory
			add: (VMLocation
				frame: robot tf frame
				timestamp: VMTimestamp new).
		
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
	].


	robot speed: (0.3@ 0.01).
	1 to: 2 do: [ :i |
		trajectory
			add: (VMLocation
				frame: robot tf frame
				timestamp: VMTimestamp new).
		
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
	].

	robot speed: (0.2@ 0.025).
	1 to: 2 do: [ :i |
		trajectory
			add: (VMLocation
				frame: robot tf frame
				timestamp: VMTimestamp new).
		
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
	].

	robot speed: (0.08@ 0.05).
	1 to: 2 do: [ :i |
		trajectory
			add: (VMLocation
				frame: robot tf frame
				timestamp: VMTimestamp new).
		
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
	].

	robot speed: (0.00@ 0.08).
	1 to: 4 do: [ :i |
		trajectory
			add: (VMLocation
				frame: robot tf frame
				timestamp: VMTimestamp new).
		
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
		robot spinOnce.
	].



]
