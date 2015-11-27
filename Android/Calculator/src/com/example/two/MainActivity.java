package com.example.two;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

public class MainActivity extends Activity {
	EditText e1,e2;
	TextView t1;
	Button a,b,c,d;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		e1 = (EditText)findViewById(R.id.editText1);
		e2 = (EditText)findViewById(R.id.editText2);
		t1 = (TextView)findViewById(R.id.textView1);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();
		if (id == R.id.action_settings) {
			return true;
		}
		return super.onOptionsItemSelected(item);
	}
	public void action(View v){
	Button temp;
	temp=(Button) v;
	String str1,str2;
	str1 = e1.getText().toString();
	str2 = e2.getText().toString();
	int num1,num2,res;
	num1 = Integer.parseInt(str1);
	num2 = Integer.parseInt(str2);
	
	switch(temp.getId()){
	case R.id.Adding:
		res=num1 + num2;
		t1.setText(res + "");
		break;
	case R.id.Subs:	
		res= num1 - num2;
		t1.setText(res + "");
		break;
	case R.id.Divide:
		res = num1 / num2;
		t1.setText(res + "");
		break;
	case R.id.Multi:
		res = num1 * num2;
		t1.setText(res + "");
		break;
	
		}
 	}
}