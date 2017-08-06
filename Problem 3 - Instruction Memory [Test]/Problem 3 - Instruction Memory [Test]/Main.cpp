#include <Windows.h>
#include <string>
#include <iostream>
#include <bitset>
#include <fstream>
#include <sstream>
#include <random>
#include <thread>

#include "CommunicationPort.h"

using namespace std;

typedef unsigned int uint;

CommunicationPort Communication;

default_random_engine generator;
uniform_int_distribution<int> distribution;

void SetupCommunicationPort ();
void GenerateTest ();
void FetchInstruction ();
void SetupStartEndInterval ();

int main () {
    SetupCommunicationPort ();
    SetupStartEndInterval ();

    uint count = 0;

    while (count < 9000) {
        GenerateTest ();
        count++;
        //Sleep (1);
        this_thread::sleep_for (chrono::nanoseconds (10));
    }
    
    return 0;
}

void SetupStartEndInterval () {
    int start = 0;
    int end = 10;

    cout << "Please, type the start number" << endl;
    if (!scanf_s ("%d", &start))
        exit (-1);

    cout << "Now, type the end number" << endl;
    if (!scanf_s ("%d", &end))
        exit (-1);

    if (end < start) {
        end ^= start;
        start ^= end;
        end ^= start;
    }

    fflush (stdin);

    distribution = uniform_int_distribution<int> (start, end);
}

void SetupCommunicationPort () {
    string user_selected_port;
    cout << "Please, type the name of the communication port that will be used" << endl;
    cout << "Port: ";

    getline (cin, user_selected_port);

    string portname = "\\\\.\\" + user_selected_port;

    cout << "Selected port: " << portname << endl;

    if (Communication.OpenPort (portname, CBR_9600, 8, ONESTOPBIT, NOPARITY) != 0) {
        cout << "Open port error" << endl;
        Sleep (6000);
        exit (-1);
        return;
    }
}

void GenerateTest () {
    uint PC = distribution (generator) * 4;
    //cout << "Random PC: " << PC << endl;

    bitset<32> binary_pc (PC);

    //cout << "Binary PC: " << binary_pc << endl;

    stringstream sstream (binary_pc.to_string());
    string output;
    while (sstream.good ()) {
        bitset<8> bits;
        sstream >> bits;
        char c = char (bits.to_ulong ());
        //cout << "C: " << c << "  - Int value " << static_cast<int>(c) << endl;
        output += c;
    }

    string value (output);
    value = output.substr (0, 4);

    Communication.SendData (value);

    FetchInstruction ();
}

void FetchInstruction () {
    Communication.SetupReceiver ();

    char PC[4];
    char a, b, c, d;

    a = Communication.ReceiveData ();
    b = Communication.ReceiveData ();
    c = Communication.ReceiveData ();
    d = Communication.ReceiveData ();

    PC[0] = a;
    PC[1] = b;
    PC[2] = c;
    PC[3] = d;

    string value (PC);
    value = value.substr (0, 4);

    //cout << " --> Instruction Fetch....: ";
    //string binary_str = "";
    for (size_t i = 0; i < 4; i++) {
        bitset<8> b (PC[i]);
        //cout << b;
        //binary_str.append(b.to_string());
    }

    //cout << " --> Instruction value: " << bitset<32> (binary_str).to_ulong() << endl;
    //cout << endl;
}