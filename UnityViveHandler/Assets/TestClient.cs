using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using System.Net;
using System.Net.Sockets;
using System.IO;

public class TestClient : MonoBehaviour {

	//NetworkClient myClient;
	//TcpListener listener;
	UdpClient udpServer2;
	IPEndPoint localpt = new IPEndPoint(IPAddress.Loopback, 12000);

	// Use this for initialization
	void Start () {
		SetupClient ();
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetKeyDown (KeyCode.S) ) {
//			Socket soc = listener.AcceptSocket();
//			Stream s = new NetworkStream(soc); 
//			StreamReader sr = new StreamReader(s);
//			StreamWriter sw = new StreamWriter(s);
//			sw.AutoFlush = true; // enable automatic flushing

			Debug.Log (udpServer2.Client.Connected);

			byte[] msg = { 0, 1, 0, 1 };
			udpServer2.Client.Send(msg);
			//bool sent = myClient.SendBytes(msg, 4, 0);
			//Debug.Log ("Message Sent: " + sent);
			//s.Close ();
		}
		
	}

	// Set up client
	void SetupClient () {
//		myClient = new NetworkClient();
//		myClient.RegisterHandler(MsgType.Connect, OnConnected);     
//		myClient.Connect("127.0.0.1", 4444);
//		myClient =  ClientScene.ConnectLocalServer();
		//listener = new TcpListener(4444);
		//listener.Start();

		udpServer2 = new UdpClient();
		udpServer2.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
		udpServer2.Client.Bind(localpt);
		udpServer2.Client.Connect (localpt);
	}

	// client function
	public void OnConnected(NetworkMessage netMsg)
	{
		Debug.Log("Connected to server");
	}
}
