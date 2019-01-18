import sys
import os
import glob
from itertools import groupby
from operator import itemgetter


class Transcriber():
    def __init__(self, trans):
        self.trans = trans
        self.rt = glob.glob(os.path.join(self.trans, "r_channel/*"))
        self.lt = [x.replace("r_channel", "l_channel").replace(".r.tran",".l.tran") for x in self.rt]
        self.conversation = []

    def r_files(self):
        return self.rt

    def l_files(self):
        return self.lt

    def conver(self):
        return self.conversation

    def read_trans(self, left_t, right_t):
        for lrt in [left_t, right_t]:
            with open(lrt, 'r') as f:
                lines = f.read().splitlines()
            lines2 =[m.split() for m in lines]
            self.conversation = self.conversation+lines2

    def preprocess(self):
        for utt in self.conversation:
            utt[2] = float(utt[2])
            utt[3] = float(utt[3])
            utt[-1]= float(utt[-1])
        self.conversation = sorted(self.conversation, key=itemgetter(2))

    def genkey(self, conv):
        return conv[0]

    def group(self):
        full = []
        for key, g in groupby(self.conversation, key=self.genkey):
            full.append(list(g))

        return full

    def to_string(self, full_list):
        tot_conv = ''
        for num, person in enumerate(full_list):
            oe = 1
            if num%2==0:
                oe = 1
            else: oe = 2
            tot_conv= tot_conv+"channel-"+str(oe)+": "
            sen = ''
            for sentence in person:
                sen = sen+sentence[4]+' '
            sen = sen+"\n\n"
            tot_conv= tot_conv+sen
        return tot_conv

    def to_file(self, full_list, path, name):

        conversation_str = self.to_string(full_list)
        try:
            with open(os.path.join(path, name), 'w') as t:
                t.write(conversation_str)
            return True
        except:
            print("Wrong Path!!!")
            return False


if __name__ == '__main__':

    trans_folder = 'transcribed'
    output = os.path.join(trans_folder, "final")
    if not os.path.exists(output):
        os.makedirs(output)

    transcriber = Transcriber(trans_folder)
    rchannel_files = transcriber.r_files()
    lchannel_files = transcriber.l_files()
    #print(rchannel_files, lchannel_files)

    assert len(rchannel_files)==len(lchannel_files) ## R or L channel transcription does not exist for some file

    ### for testing
    #transcriber.read_trans(lchannel_files[0], rchannel_files[0])
    #transcriber.preprocess()
    #filename = val.split('/')[-1].split('.')[0]+'.txt'
    #convo_list = transcriber.group()
    #transcriber.to_file(convo_list, output, filename)


    for num, val in enumerate(rchannel_files):
        #print(lchannel_files[num], val, num)
        transcriber.read_trans(lchannel_files[num], val)
        transcriber.preprocess()
        filename = val.split('/')[-1].split('.')[0]+'.txt'
        print(filename)
        convo_list = transcriber.group()
        transcriber.to_file(convo_list, output, filename)
    print("Done")
