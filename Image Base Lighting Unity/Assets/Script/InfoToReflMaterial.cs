using UnityEngine;
using System.Collections;

public class InfoToReflMaterial : MonoBehaviour {

    // The proxy volume used for local reflection calculations.
    public GameObject boundingBox;

    void Start()
    {
        Vector3 bboxLenght = boundingBox.GetComponent<ReflectionProbe>().size;
        Vector3 centerBBox = boundingBox.transform.position;
        // Min and max BBox points in world coordinates.
        Vector3 BMin = centerBBox - bboxLenght / 2;
        Vector3 BMax = centerBBox + bboxLenght / 2;
        Renderer curRenderer = gameObject.GetComponent<Renderer>();
        // Pass the values to the material.

        curRenderer.sharedMaterial.SetVector("_boxMin", BMin);
        curRenderer.sharedMaterial.SetVector("_boxMax", BMax);
        curRenderer.sharedMaterial.SetVector("_cubemapPos", centerBBox);
    }
}
