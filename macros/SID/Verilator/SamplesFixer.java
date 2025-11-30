import java.io.*;

public class SamplesFixer {
	public static void main(String[] args) {
		try {
			boolean mono = args.length > 0 && args[0].equals("M");
			FileInputStream fis = new FileInputStream("obj_dir/samples.bin");
			fis.skip(4);
			FileOutputStream fos = new FileOutputStream("samples_8.bin");
			while(fis.available() > 0) {
				short sample = (short)fis.read();
				sample |= (short)fis.read() << 8;
				sample -= 2048;
				sample *= 15;
				int usample = sample & 0xFFFF;
				fos.write(usample >> 8);
				fos.write(usample & 0xFF);
				fis.read();
				fis.read();
				if(mono) {
					fis.read();
					fis.read();
					fis.read();
					fis.read();
				}
			}
			fos.close();
			fis.close();
		}catch(Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
