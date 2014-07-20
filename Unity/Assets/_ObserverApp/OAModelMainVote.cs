using UnityEngine;
using System.Collections;

public class OAModelMainVote : MonoBehaviour {
	public int number;
	public UILabel label;
	public void add(){
		number+=1;
		label.text=number+"";
	}
}
