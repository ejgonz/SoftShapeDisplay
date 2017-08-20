/// <summary>
/// Script for for updating position and rotation of target object using Vive tracker
/// Adapted from ShapeCast.cs in PinDisplay Unity project by A. Siu.
/// Author: E. Gonzalez
/// August 20, 2017
/// </summary>

using UnityEngine;
using System.Collections.Generic;
using UnityEngine.VR;
using ExtensionMethods; //for median calculation in window filtering

public class ViveTarget : MonoBehaviour {
    // ***    User defined variables    ** //

    #region tracking devices
    public bool UseViveTrack = true;
    public GameObject ViveTracker;
    public GameObject ViveOrigin;
    private bool initViveDone = false;
    private float initViveTime = 1.0f;
    private float startViveTime;

    [Tooltip("distance of x-axis between tracker and shape disp")]
    public float dx = 0.0f;
    [Tooltip("distance of y-axis between tracker and shape disp")]
    public float dy = 0.0f;
    [Tooltip("distance of z-axis between tracker and shape disp ")]
    public float dz = 0.0f;
    [Tooltip("angle in x-axis between tracker and shape display")]
    public float yaw = 0.0f;
    [Tooltip("angle in y-axis between tracker and shape display")]
    public float pitch = 0.0f;
    [Tooltip("angle in y-axis between tracker and shape display")]
    public float roll = 0.0f;
    #endregion tracking devices

    #region median average parameters
    private List<float> windowPosX;
    private List<float> windowPosY;
    private List<float> windowPosZ;
    private List<float> windowRotX;
    private List<float> windowRotY;
    private List<float> windowRotZ;
    public int windowSizeX = 8;
    public int windowSizeY = 8;
    public int windowSizeZ = 8;
    public int windowSizeXrot = 8;
    public int windowSizeYrot = 8;
    public int windowSizeZrot = 8;
    #endregion median average parameters

    void Start() {
        if (UseViveTrack)
        {
            // save time to know when to initialize the display
            startViveTime = Time.time;
            initViveDone = false;

            // init filtering window
            windowPosX = new List<float>();
            windowPosY = new List<float>();
            windowPosZ = new List<float>();
            windowRotX = new List<float>();
            windowRotY = new List<float>();
            windowRotZ = new List<float>();
            for (int i = 0; i < windowSizeX; i++)
            {
                windowPosX.Add(0.0f);
            }
            for (int i = 0; i < windowSizeY; i++)
            {
                windowPosY.Add(0.0f);
            }
            for (int i = 0; i < windowSizeZ; i++)
            {
                windowPosZ.Add(0.0f);
            }
            for (int i = 0; i < windowSizeXrot; i++)
            {
                windowRotX.Add(0.0f);
            }
            for (int i = 0; i < windowSizeYrot; i++)
            {
                windowRotY.Add(0.0f);
            }
            for (int i = 0; i < windowSizeZrot; i++)
            {
                windowRotZ.Add(0.0f);
            }
        }
    }

// Update is called once per frame
void FixedUpdate () {
        if (UseViveTrack)
        {

            Vector3 deltaDisplacement = new Vector3(dx, dy, dz);
            Quaternion deltaRotation = Quaternion.Euler(roll, yaw, pitch);

            Quaternion newRot = ViveTracker.transform.rotation * deltaRotation;
            Vector3 newPos = ViveTracker.transform.position +
                             (ViveTracker.transform.rotation * deltaRotation)
                             * deltaDisplacement;

            // add positions + rot to filtering window
            windowPosX.RemoveAt(0); windowPosX.Add(newPos.x);
            windowPosY.RemoveAt(0); windowPosY.Add(newPos.y);
            windowPosZ.RemoveAt(0); windowPosZ.Add(newPos.z);
            windowRotX.RemoveAt(0); windowRotX.Add(newRot.eulerAngles.x);
            windowRotY.RemoveAt(0); windowRotY.Add(newRot.eulerAngles.y);
            windowRotZ.RemoveAt(0); windowRotZ.Add(newRot.eulerAngles.z);

            /// do a median average
            //float currXpos = windowPosX.Sum() / windowSizeX; //windowPosX.GetMedian();
            //float currYpos = windowPosY.Sum() / windowSizeY; ///windowPosY.GetMedian();
            //float currZpos = windowPosZ.Sum() / windowSizeZ; //windowPosZ.GetMedian();
            //float currXrot = windowRotX.Sum() / windowSizeXrot; // windowRotX.GetMedian();
            //float currYrot = windowRotY.Sum() / windowSizeYrot; //windowRotY.GetMedian();
            //float currZrot = windowRotZ.Sum() / windowSizeZrot; //windowRotZ.GetMedian();

            float currXpos = windowPosX.GetMedian();
            float currYpos = windowPosY.GetMedian();
            float currZpos = windowPosZ.GetMedian();
            float currXrot = windowRotX.GetMedian();
            float currYrot = windowRotY.GetMedian();
            float currZrot = windowRotZ.GetMedian();

            // assign the position
            this.transform.position = new Vector3(currXpos, currYpos, currZpos);
            //this.transform.position = new Vector3(newPos.x, newPos.y, newPos.z);
            this.transform.rotation = Quaternion.Euler(0, currYrot, 0);
            //this.transform.rotation = Quaternion.Euler(newRot.x, newRot.y, newRot.z);

        }
    }
}
