;; -*- lexical-binding: t -*-

(ert-deftest rustic-test-save-some-buffers ()
  (let* ((buffer1 (get-buffer-create "b1"))
         (buffer2 (get-buffer-create "b2"))
         (string "fn main()      {}")
         (formatted-string "fn main() {}\n")
         (dir (rustic-babel-generate-project t)))
    (let* ((default-directory dir)
           (src (concat dir "/src"))
           (file1 (expand-file-name "main.rs" src))
           (file2 (progn (shell-command-to-string "touch src/test.rs")
                         (expand-file-name "test.rs" src))))
      (with-current-buffer buffer1
        (write-file file1)
        (insert string))
      (with-current-buffer buffer2
        (write-file file2)
        (insert string))
      (let ((buffer-save-without-query t))
        (rustic-save-some-buffers))
      (with-current-buffer buffer1
        (should (string= (buffer-string) formatted-string)))
      (with-current-buffer buffer2
        (should (string= (buffer-string) formatted-string))))))

(ert-deftest rustic-test-compile ()
  (let* ((buffer1 (get-buffer-create "compile"))
         (dir (rustic-babel-generate-project t)))
    (should-not compilation-directory)
    (should-not compilation-arguments)
    (let* ((default-directory dir)
           (proc (rustic-compile)))
      (should-error (rustic-compile))
      (should (process-live-p proc))
      (while (eq (process-status proc) 'run)
          (sit-for 0.1))
      (should compilation-arguments)
      (should compilation-directory))))
