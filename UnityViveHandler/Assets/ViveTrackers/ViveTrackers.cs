/// <summary>
/// Read transform data from selected HTC Vive trackers.
/// Author: A. Siu
/// August 9, 2017
/// </summary>
/// 
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Valve.VR;

public class ViveTrackers : MonoBehaviour {

    [Tooltip("Index of tracker 1")]
    public int originID = 1;
    [Tooltip("Index of tracker 2")]
    public int trackerID = 2;

    public GameObject ViveOrigin;
    public GameObject ViveTracker;

    [Tooltip("True if need to calibrate tracker positioning")]
    public bool Calibrate = false;
    
    private CVRSystem vrSystem;
    
    // Use this for initialization
    void Start () {

        Debug.Log("Finding Vive Devices:");
        var error = EVRInitError.None;
        vrSystem = OpenVR.Init(ref error, EVRApplicationType.VRApplication_Other);
        //The tracker will be classified as ETrackedDeviceClass.GenericTracker.
        if (error != EVRInitError.None)
        {
            // handle init error
            Debug.Log("EVR Init Error");
        }
        PrintOpenVRDevices();

        ViveOrigin = GameObject.Find("ViveOrigin");
        ViveTracker = GameObject.Find("ViveTracker");

    }
	
	// Update is called once per frame
	void Update () {

        // Set the ViveOrigin tranform
        //ViveOrigin.transform.rotation = SteamVR_Controller.Input(originID).transform.rot;
        //ViveOrigin.transform.position = SteamVR_Controller.Input(originID).transform.pos;
        ViveOrigin.transform.rotation = Quaternion.Euler(-89.47501f, -108.28f, -9.868f);
        ViveOrigin.transform.position = new Vector3(0.6069773f, -1.373294f, 0.7243462f);  //-1.3637f, 0.73742f);

        // Set the ViveTracker tranform
        ViveTracker.transform.rotation = SteamVR_Controller.Input(trackerID).transform.rot;
        ViveTracker.transform.position = SteamVR_Controller.Input(trackerID).transform.pos;

        // Find the relative position between two markers. This is useful to
        // determine calibration offsets such as dx, dy, dz, yaw, pitch, roll.
        if (Calibrate)
        {
            Debug.Log("o-rot: " + ViveOrigin.transform.rotation.eulerAngles);
            Debug.Log("o-pos: " + ViveOrigin.transform.position);
            Debug.Log("t-rot: " + ViveTracker.transform.rotation.eulerAngles);
            Debug.Log("t-pos: " + ViveTracker.transform.position);
            Vector3 relativePos = -ViveOrigin.transform.position + ViveTracker.transform.position;
            Quaternion relativeRot = ViveOrigin.transform.rotation * Quaternion.Inverse(ViveTracker.transform.rotation);
            Vector3 newPosMeas = new Vector3(0.3f, -1.1f, 0.7f);
            Quaternion newRotMeas = Quaternion.Euler(341.1f, 90.8f, 89.9f);
            relativePos = -newPosMeas + ViveTracker.transform.position;
            relativeRot = newRotMeas * Quaternion.Inverse(ViveTracker.transform.rotation);
            Debug.Log("rel pos: " + relativePos);
            Debug.Log("rel rot: " + relativeRot.eulerAngles);
        }
        
    }
    
    /// <summary>
    /// Print all available VR devices.
    /// </summary>
    private void PrintOpenVRDevices()
    {
        for (uint i = 0; i < OpenVR.k_unMaxTrackedDeviceCount; i++)
        {
            var deviceClass = vrSystem.GetTrackedDeviceClass(i);
            if (deviceClass != ETrackedDeviceClass.Invalid)
            {
                //var deviceReading = 0;// GetDeviceReading(i);
                Debug.Log("OpenVR device at " + i + ": " + deviceClass); // + " and pos " + deviceReading);
            }
        }
    }

}
