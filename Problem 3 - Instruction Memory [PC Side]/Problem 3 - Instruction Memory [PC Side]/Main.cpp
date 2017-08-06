#include <Windows.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <bitset>
#include <string>
#include <vector>

#include "CommunicationPort.h"

typedef unsigned int uint;

using namespace std;

int main ();

void SetupInstructionMemory ();
void SetupCommunicationPort ();
bool PrepareInstructionLine (const string& line, bool b = false);
void ClosePort ();
void PrepareToReadPC ();
void FetchAndSendInstruction (uint index);

string NOP_INSTRUCTION;

vector<string> Instructions;
vector<string> InstructionsAsString;
CommunicationPort Communication;

int main () {
    SetupInstructionMemory ();
    SetupCommunicationPort ();

    //Communication.SendData ("test");

    uint count = 0;

    while (count < 9000) {
        PrepareToReadPC ();
        count++;
    }

    int d;
    scanf_s ("%d", &d);
    ClosePort ();
    return 0;
}

/**
 * Read the binary instructions from a file.
 */
void SetupInstructionMemory () {
    string filename;
    cout << "Please, enter the name of the binary file to load into memory." << endl;
    cout << "File: ";
    getline (cin, filename);

    cout << "\nSelected File: " << filename << endl;

    ifstream file (filename);

    if (!file.good ()) {
        cout << "File not opened. Does it really exists? Program will now exit" << endl;
        Sleep (5000);
        exit (-1);
    }

    
    string line;
    size_t i = 0;
    while (getline (file, line)) {
        i++;
        if (!PrepareInstructionLine (line)) {
            cout << "Error at line: " << i << ". Program will now exit." << endl;
            Sleep (5000);
            exit (-1);
        }
    }

    PrepareInstructionLine ("00000000000000000000000000000000", true);

    cout << "File successfully read" << endl;
}

/**
 * Open and configure the port
 */
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

void ClosePort () {
    Communication.ClosePort ();
}

bool PrepareInstructionLine (const string& line, bool b) {
    if (line.length () != 32) {
        cout << " --> Line doesn't have 32bits. It has " << line.length () << "." << endl;
        return false;
    }

    for (int i = 0; i < line.length (); i++) {
        char c = line.at (i);
        if (c != '0' && c != '1') {
            cout << " --> Illegal characters. Only 1's and 0's are allowed." << endl;
            return false;
        }

    }

    stringstream sstream (line);
    string output;
    while (sstream.good ()) {
        bitset<8> bits;
        sstream >> bits;
        char c = char (bits.to_ulong ());
        output += c;
    }

    output = output.substr (0, 4);
    //cout << " -------> Output: " << output << endl;
    //cout << "Line Len: " << output.length () << endl;
    if (!b) {
        Instructions.push_back (output);
        InstructionsAsString.push_back (line);
    }
    else {
        NOP_INSTRUCTION = output;
    }

    return true;
}


void PrepareToReadPC () {
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

    //cout << "Values: " << static_cast<int>(a) << " " << static_cast<int>(b) << " " << static_cast<int>(c) << " " << static_cast<int>(d) << endl;

    string value (PC);
    value = value.substr (0, 4);

    cout << " --> Binary PC....: ";
    string binary_str = "";
    for (size_t i = 0; i < 4; i++) {
        bitset<8> b (PC[i]);
        cout << b;
        binary_str.append (b.to_string ());
    }
    cout << endl;

    uint index = bitset<32> (binary_str).to_ulong ();
    cout << " --> PC Raw Addr..: " << index << endl;
    index = index / 4;
    cout << " --> PC Address...: " << index << endl;
    
    FetchAndSendInstruction (index);
    return;
}

void FetchAndSendInstruction (uint index) {
    string instruction;

    if (Instructions.size () <= index) {
        cout << "PC is out of boundaries. Sending NOP..." << endl;
        instruction = NOP_INSTRUCTION;
    }
    else {
        instruction = Instructions.at (index);
        string ground_truth = InstructionsAsString.at (index);
        cout << "Selected Instruction: " << ground_truth << " - Value: " << bitset<32>(ground_truth).to_ulong() << endl;

        const char* INST = instruction.c_str ();

        string binary_str = "";
        for (size_t i = 0; i < 4; i++) {
            bitset<8> b (INST[i]);
            binary_str.append (b.to_string ());
        }

        if (binary_str.compare (ground_truth) != 0) {
            cout << "Generated String is not the binary in file. DANGER!!!" << endl;
            cout << "Info> Index: " << index << endl;
            Sleep (6000);
            exit (-1);
        }

    }

    

    Communication.SendData (instruction);

    cout << "------------------------------------------" << endl;
    return;
}