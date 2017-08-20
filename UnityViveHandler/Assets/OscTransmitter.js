// Make sure you have UDPPacketIO.cs and Osc.cs in the standard assets folder

var RemoteIP : String = "127.0.0.1";
var SendToPort : int = 57131;
var ListenerPort : int = 57130;
var target : GameObject;

private var controller : Transform; 
private var handler : Osc;
private var RAD2DEG = 180.0/Mathf.PI;

public function Start ()
{	
	// Set up OSC connection
	var udp : UDPPacketIO = GetComponent("UDPPacketIO");
	udp.init(RemoteIP, SendToPort, ListenerPort);
	handler = GetComponent("Osc");
	handler.init(udp);
}

function FixedUpdate () {

//	if (Input.GetKeyDown ("space")) {
//		// Set variable	
//		var x = 10.0;
//		var y = 15.0;
//		var r = 30.0;
//
		var data  = new Array();
		data[0] = target.transform.position.x;
		data[1] = target.transform.position.z;
		data[2] = target.transform.rotation.y * RAD2DEG;

		var msg : OscMessage = new OscMessage();
		msg.Address = "/viveData";
		msg.Values = new ArrayList(data);

		handler.Send(msg);

//		Debug.Log("Sent msg: " + data[0] + " " + data[1] + " " + data[2]);
//	}
}
