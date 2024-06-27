from PySide6.QtCore import Signal, Slot, QObject, QUrl, Property
from PySide6.QtQml import QmlElement
import yaml, math, requests, os

QML_IMPORT_NAME = "AppLogic"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class AppLogic(QObject):
    parentChanged = Signal(QObject)
    
    def __init__(self):
        super().__init__()
        
    @Property(QObject)
    def parent(self) -> QObject:
        return super().parent()
    
    @parent.setter
    def parent(self, parent: QObject):
        super().setParent(parent)
        self.parentChanged.emit(parent)

    @Slot(result=dict)
    def checkUpdate(self):
        current_version = self.getVersion()
        url = f"https://api.github.com/repos/davidyusaku-13/sensetool-viewtrix/releases/latest"
        response = requests.get(url)
        if response.status_code == 200:
            latest_release = response.json()
            latest_version = latest_release['tag_name']
            if latest_version >= current_version:
                status = True
                release_notes = latest_release['body']
                download_url = latest_release['assets'][0]['browser_download_url'] if latest_release['assets'] else latest_release['zipball_url']
            else:
                status = False
                release_notes = ""
                download_url = ""
        else:
            print(f"Failed to fetch the latest release information. Status code: {response.status_code}")
        return {"status": status, "version": latest_version, "changelog": release_notes, "link": download_url}
        
    @Slot(result=str)
    def getVersion(self):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        versionpath = os.path.join(script_dir, '../../VERSION.txt')
        with open(versionpath, 'r') as f:
            version = f.read().strip()
        return version

    @Slot(list, result=list)
    def divideArray(self, array):
        evenArray = [array[i] for i in range(len(array)) if i % 2 == 0]
        oddArray = [array[i] for i in range(len(array)) if i % 2 != 0]
        return [evenArray, oddArray]

    @Slot(int, float, str, result=list)
    def win_coef_gen(self, win_sample_number, win_a0, win_length):
        Win_step = 1
        Sample_Number = win_sample_number
        Win_N = Sample_Number // Win_step
        a0 = win_a0
        a1 = 1 - a0
        Window_arr = []
        for i in range(1, Win_N + 1):
            val = a0 - a1 * math.cos(2 * math.pi * (i - 1) /
                                     (Sample_Number / Win_step - 1))
            Window_arr.append(round(val * 256))
        if (win_length == "Half"):
            return Window_arr[:len(Window_arr)//2]
        else:
            return Window_arr

    @Slot(QUrl, list, int, float, str)
    def exportWinCoef(self, fname, y, win_sample_number, win_a0, win_coef_length):
        file_name = fname.toLocalFile()
        yaml_data = {
            'sample_number': win_sample_number,
            'a0': win_a0,
            'coef_length': win_coef_length,
            'data': []
        }

        for i in range(len(y)):
            yaml_item = {
                'y': y[i]
            }
            yaml_data['data'].append(yaml_item)

        with open(file_name, 'w') as file:
            yaml.dump(yaml_data, file, sort_keys=False)

    @Slot(QUrl, result=list)
    def importWinCoef(self, fname):
        file_name = fname.toLocalFile()
        arr = []
        try:
            with open(file_name, 'r') as yaml_file:
                yaml_data = yaml.load(yaml_file, Loader=yaml.FullLoader)
                if isinstance(yaml_data['data'], list):
                    for item in yaml_data['data']:
                        y = item['y']
                        arr.append(y)
                else:
                    print("Invalid YAML format. Expected a list.")
                if 'sample_number' in yaml_data and 'a0' in yaml_data and 'coef_length' in yaml_data:
                    sample_number = yaml_data['sample_number']
                    a0 = yaml_data['a0']
                    coef_length = yaml_data['coef_length']
                else:
                    print("Sample Number, a0, and Coef Length must not be empty")
        except FileNotFoundError:
            print("File not found:", file_name)
        except yaml.YAMLError as e:
            print("Error loading YAML:", e)
        return [arr, sample_number, a0, coef_length]
    
    @Slot(int, int, int, int, result=list)
    def demo_coef_gen(self, demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq):
        I_Coef = []
        Q_Coef = []
        Num_step = demo_num_step
        Sample_Number = demo_sample_number
        N = Num_step * 4
        Cycle = demo_cycle
        Pen_Frequency = 1 / (N/Cycle/demo_adc_sampling_freq)
        for i in range(1, Sample_Number+1):
            I_Coef.append(round(math.sin(2*math.pi*Cycle*(i-1)/N)*0.5*256))
            Q_Coef.append(round(math.cos(2*math.pi*Cycle*(i-1)/N)*0.5*256))
        return [I_Coef, Q_Coef]

    @Slot(QUrl, list, int, int, int, int)
    def exportDemoCoef(self, fname, y, demo_step, demo_sample, demo_cycle, demo_adc):
        y_sin, y_cos = y
        file_name = fname.toLocalFile()
        yaml_data = {
            'step': demo_step,
            'sample': demo_sample,
            'cycle': demo_cycle,
            'adc_freq': demo_adc,
            'i_coef': [],
            'q_coef': []
        }

        for i in range(len(y_sin)):
            yaml_item = {
                'y_sin': y_sin[i]
            }
            yaml_data['i_coef'].append(yaml_item)

        for i in range(len(y_cos)):
            yaml_item = {
                'y_cos': y_cos[i]
            }
            yaml_data['q_coef'].append(yaml_item)

        with open(file_name, 'w') as file:
            yaml.dump(yaml_data, file, sort_keys=False)

    @Slot(QUrl, result=list)
    def importDemoCoef(self, fname):
        file_name = fname.toLocalFile()
        sinArr = []
        cosArr = []
        try:
            with open(file_name, 'r') as yaml_file:
                yaml_data = yaml.load(yaml_file, Loader=yaml.FullLoader)
                if isinstance(yaml_data['i_coef'], list):
                    for item in yaml_data['i_coef']:
                        y_sin = item['y_sin']
                        sinArr.append(y_sin)
                if isinstance(yaml_data['q_coef'], list):
                    for item in yaml_data['q_coef']:
                        y_cos = item['y_cos']
                        cosArr.append(y_cos)
                if 'step' in yaml_data and 'sample' in yaml_data and 'cycle' in yaml_data and 'adc_freq' in yaml_data:
                    step = yaml_data['step']
                    sample = yaml_data['sample']
                    cycle = yaml_data['cycle']
                    adc_freq = yaml_data['adc_freq']
                else:
                    print("Invalid YAML format. Expected a list.")
        except FileNotFoundError:
            print("File not found:", file_name)
        except yaml.YAMLError as e:
            print("Error loading YAML:", e)
        return [[sinArr, cosArr], step, sample, cycle, adc_freq]
